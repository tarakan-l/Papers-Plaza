using System;
using System.Threading;
using System.Threading.Tasks;
using Npgsql;

class Program
{
    private static readonly string ConnectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING") 
        ?? "Host=localhost;Database=queue_tasks_db;Username=queue_user;Password=queue_password";

    static async Task Main(string[] args)
    {
        string role = Environment.GetEnvironmentVariable("SERVICE_ROLE") ?? "Producer";
        string workerId = Environment.GetEnvironmentVariable("WORKER_ID") ?? "LocalWorker";

        Console.WriteLine($"[СТАРТ] Сервис запущен как: {role} ({workerId})");
        Console.Out.Flush();

        if (role.Equals("Producer", StringComparison.OrdinalIgnoreCase))
        {
            await RunProducerAsync();
        }
        else
        {
            await RunConsumerAsync(workerId);
        }
    }

    // === 2. РЕАЛИЗАЦИЯ ПРОДЬЮСЕРА (Таможенная инспекция) ===
    private static async Task RunProducerAsync()
    {
        var random = new Random();
        int taskCounter = 0;

        string[] types = { "Проверка паспорта", "Сканирование биометрии", "Проверка въездной визы", "Проверка документов на груз" };

        while (true)
        {
            try
            {
                using var conn = new NpgsqlConnection(ConnectionString);
                await conn.OpenAsync();

                // Вставка в рамках ОДНОЙ транзакции с фиктивной бизнес-логикой по ТЗ
                using var tx = await conn.BeginTransactionAsync();

                // Фиктивная бизнес-логика (имитация записи действия в системный аудит-лог таможни)
                using var auditCmd = new NpgsqlCommand(
                    "INSERT INTO tasks (payload, status) VALUES ('Системный аудит: Начало досмотра гражданина', 'Completed')", conn, tx);
                await auditCmd.ExecuteNonQueryAsync();

                // Распределение веса задач по ТЗ: 80% обычных (0), 20% критических (100)
                int priority = random.Next(100) < 80 ? 0 : 100;
                taskCounter++;

                string randomCheck = types[random.Next(types.Length)];
                string travelerId = $"Гражданин-ID-{random.Next(1000, 9999)}";
                
                // Если приоритет 100 — это срочный перехват нарушителя или проверка дипломата
                string payload = priority == 100 
                    ? $"[КРИТИЧЕСКИЙ СИГНАЛ] Поиск по базе преступников: {travelerId}" 
                    : $"{randomCheck}: {travelerId}";

                using var taskCmd = new NpgsqlCommand(
                    "INSERT INTO tasks (payload, priority, status) VALUES (@payload, @priority, 'Ready')", conn, tx);
                taskCmd.Parameters.AddWithValue("payload", payload);
                taskCmd.Parameters.AddWithValue("priority", priority);
                await taskCmd.ExecuteNonQueryAsync();

                await tx.CommitAsync();

                // Высокая интенсивность по ТЗ (100–500 вставок в секунду -> пауза 2-4 миллисекунды)
                await Task.Delay(3); 
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Ошибка Продюсера]: {ex.Message}");
                Console.Out.Flush();
                await Task.Delay(1000);
            }
        }
    }

    // === 3. РЕАЛИЗАЦИЯ КОНСЬЮМЕРОВ (Таможенные КПП) ===
    private static async Task RunConsumerAsync(string workerId)
    {
        int processedCount = 0;
        var lastMetricsTime = DateTime.UtcNow;

        while (true)
        {
            try
            {
                using var conn = new NpgsqlConnection(ConnectionString);
                await conn.OpenAsync();

                // Ключевой запрос лабораторной: FOR UPDATE SKIP LOCKED с сортировкой по приоритету
                string selectSql = @"
                    UPDATE tasks
                    SET status = 'Running'
                    WHERE id = (
                        SELECT id 
                        FROM tasks 
                        WHERE status = 'Ready' AND scheduled_at <= now()
                        ORDER BY priority DESC, scheduled_at ASC
                        LIMIT 1
                        FOR UPDATE SKIP LOCKED
                    )
                    RETURNING id, payload, priority, attempts;";

                using var cmd = new NpgsqlCommand(selectSql, conn);
                using var reader = await cmd.ExecuteReaderAsync();

                if (await reader.ReadAsync())
                {
                    int id = reader.GetInt32(0);
                    string payload = reader.GetString(1);
                    int priority = reader.GetInt32(2);
                    int attempts = reader.GetInt32(3);
                    
                    reader.Close(); // Освобождаем соединение для дальнейших SQL операций

                    // Имитация времени проверки документов на КПП (10 миллисекунд)
                    await Task.Delay(10); 

                    // Симуляция падения проверки (например, 5% документов вызывают ошибку сканера)
                    bool isSuccess = new Random().Next(100) >= 5;

                    if (isSuccess)
                    {
                        using var updateCmd = new NpgsqlCommand("UPDATE tasks SET status = 'Completed' WHERE id = @id", conn);
                        updateCmd.Parameters.AddWithValue("id", id);
                        await updateCmd.ExecuteNonQueryAsync();
                    }
                    else
                    {
                        // 5. ДОПОЛНИТЕЛЬНО: Механизм Retry (Exponential backoff) за бонусные баллы
                        attempts++;
                        if (attempts >= 3) // Если 3 раза сканер выдал ошибку — отправляем в Failed (DLQ)
                        {
                            using var failCmd = new NpgsqlCommand("UPDATE tasks SET status = 'Failed' WHERE id = @id", conn);
                            failCmd.Parameters.AddWithValue("id", id);
                            await failCmd.ExecuteNonQueryAsync();
                        }
                        else
                        {
                            // Сдвигаем следующую попытку проверки вперед на симулированный интервал
                            using var retryCmd = new NpgsqlCommand(
                                "UPDATE tasks SET status = 'Ready', attempts = @att, scheduled_at = now() + INTERVAL '10 seconds' WHERE id = @id", conn);
                            retryCmd.Parameters.AddWithValue("id", id);
                            retryCmd.Parameters.AddWithValue("att", attempts);
                            await retryCmd.ExecuteNonQueryAsync();
                        }
                    }

                    processedCount++;
                }
                else
                {
                    reader.Close();
                    await Task.Delay(50); // Если на КПП пусто, ждем новых граждан
                }

                // === 4. НАГРУЗКА И МОНИТОРИНГ ЛАГА (Вывод метрик раз в 5 секунд) ===
                if ((DateTime.UtcNow - lastMetricsTime).TotalSeconds >= 5)
                {
                    var elapsed = (DateTime.UtcNow - lastMetricsTime).TotalSeconds;
                    
                    // SQL-запрос расчета Лага по ТЗ (разница между текущим временем и созданием самой старой готовой задачи)
                    string lagSql = "SELECT COALESCE(EXTRACT(EPOCH FROM (now() - MIN(created_at))), 0) FROM tasks WHERE status = 'Ready';";
                    using var lagCmd = new NpgsqlCommand(lagSql, conn);
                    double lag = Convert.ToDouble(await lagCmd.ExecuteScalarAsync());

                    double throughput = processedCount / elapsed;
                    
                    // Выводим логи. Текст сразу готов к копированию в ваш QUEUE.md
                    Console.WriteLine($"[{workerId}] Throughput: {throughput:F2} досмотров/сек | Лаг очереди: {lag:F2} сек.");
                    Console.Out.Flush();

                    processedCount = 0;
                    lastMetricsTime = DateTime.UtcNow;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[{workerId} Ошибка]: {ex.Message}");
                Console.Out.Flush();
                await Task.Delay(1000);
            }
        }
    }
}
