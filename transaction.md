<img width="1064" height="1198" alt="изображение" src="https://github.com/user-attachments/assets/a44d2ed7-0f4b-49d8-95ab-22ae1e01ceb1" />

## Базовые транзакции

1. COMMIT

1.1. Добавление нового пользователя, а потом присвоение ему новой биометрии
```sql
BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
     'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1
)

WITH new_biometry AS (
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id
)
UPDATE identity.passport
SET 
    biometry = new_biometry.id
FROM new_biometry
WHERE fullName = 'Евгений Жидко';

COMMIT;
```

2. ROLLBACK

2.1. Добавление нового пользователя, а потом присвоение ему новой биометрии (ROLLBACK-версия)
```sql
BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
    'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1
)

WITH new_biometry AS (
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id
)
UPDATE identity.passport
SET 
    biometry = new_biometry.id
FROM new_biometry
WHERE fullName = 'Евгений Жидко';

ROLLBACK;
```
Изначально
![фото](transactions_screenshots/2_1_start.png)

До rollback
![фото](transactions_screenshots/2_1_do.png)

После rollback
![фото](transactions_screenshots/2_1_posle.png)

3. ERROR

3.1. Добавление нового пользователя с невозможным id
```sql

BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
    'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1 / 0
)

ROLLBACK;
```

## Isolation levels

4. READ UNCOMMITTED / READ COMMITTED - Попытка прочитать грязные данные (неудачная)

4.1. Добавление нового пользователя и откат, между этим попытка его обнаружить
```csharp

using Npgsql;

string ConnectionString = "Host=localhost;Username=postgres;Password=;Database=PapersPlease";

bool canRead = false;
bool canRollBack = false;

var insert = Task.Run(async () =>
{
    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadUncommitted);

    var sql =
    """
    INSERT INTO identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    ) VALUES (
        'Горбуша сырокопчёная',
        '2023-01-15',
        '2033-01-15',
        1,
        1
    )
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    await cmd.ExecuteNonQueryAsync();
    Console.WriteLine("F1 Insert done");
    canRead = true;

    while (!canRollBack)
    {
        await Task.Delay(1000);
    }

    await transaction.RollbackAsync();
    Console.WriteLine("F1 Rollback done");
});

var read = Task.Run(async () =>
{
    while (!canRead)
    {
        await Task.Delay(1000);
    }

    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadUncommitted);

    var sql =
    """
    SELECT COUNT(*)
    FROM identity.passport
    WHERE fullName = 'Горбуша сырокопчёная';
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    var res = await cmd.ExecuteScalarAsync();

    await transaction.CommitAsync();

    Console.WriteLine($"F2 Select done: {res}");
    canRollBack = true;
});

await Task.WhenAll(insert, read);
```

![фото](transactions_screenshots/4_1.png)


5. READ COMMITTED - Неповторяющееся чтение

5.1. Попытка считать количество пользователей до изменения и после

```csharp

using Npgsql;

string ConnectionString = "Host=localhost;Username=postgres;Password=9492;Database=PapersPlease";

bool canEdit = false;
bool canTryAgain = false;

var insert = Task.Run(async () =>
{
    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadCommitted);

    var sql =
    """
    SELECT COUNT(*)
    FROM identity.passport
    WHERE fullName = 'Евгений Жидко';
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    var res = await cmd.ExecuteScalarAsync();

    Console.WriteLine($"F2 Select-1 done: {res}");
    canEdit = true;

    while (!canTryAgain)
    {
        await Task.Delay(1000);
    }

    await using var cmd2 = new NpgsqlCommand(sql, conn, transaction);
    var res2 = await cmd.ExecuteScalarAsync();

    Console.WriteLine($"F2 Select-2 done: {res2}");

    await transaction.CommitAsync();
});

var read = Task.Run(async () =>
{
    while (!canEdit)
    {
        await Task.Delay(1000);
    }

    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadCommitted);

    var sql =
    """
    UPDATE identity.passport
    SET
        fullName = 'Евгений Твёрдо'
    WHERE fullName = 'Евгений Жидко';
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    await cmd.ExecuteNonQueryAsync();
    Console.WriteLine("F1 Insert done");

    await transaction.CommitAsync();
    Console.WriteLine("F1 Commit done");

    canTryAgain = true;
});

await Task.WhenAll(insert, read);
```


![фото](transactions_screenshots/5_1.png)

6. REPEATABLE READ - Невидимые изменения

6.1. Попытка считать количество пользователей до изменения и после

Код как выше, только IsolationLevel.RepeatableRead

![фото](transactions_screenshots/6_1.png)

7. REPEATABLE READ - Фантомное чтение

7.1. Попытка считать количество пользователей до добавления нового и после

```csharp

using Npgsql;

string ConnectionString = "Host=localhost;Username=postgres;Password=;Database=PapersPlease";

bool canEdit = false;
bool canTryAgain = false;

var insert = Task.Run(async () =>
{
    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadCommitted);

    var sql =
    """
    SELECT COUNT(*)
    FROM identity.passport
    WHERE fullName = 'Горбуша сырокопчёная';
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    var res = await cmd.ExecuteScalarAsync();

    Console.WriteLine($"F2 Select-1 done: {res}");
    canEdit = true;
    
    while (!canTryAgain)
    {
        await Task.Delay(1000);
    }

    await using var cmd2 = new NpgsqlCommand(sql, conn, transaction);
    var res2 = await cmd.ExecuteScalarAsync();

    Console.WriteLine($"F2 Select-2 done: {res2}");

    await transaction.CommitAsync();
});

var read = Task.Run(async () =>
{
    while (!canEdit)
    {
        await Task.Delay(1000);
    }

    await using var conn = new NpgsqlConnection(ConnectionString);
    await conn.OpenAsync();

    await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.ReadUncommitted);

    var sql =
    """
    INSERT INTO identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    ) VALUES (
        'Горбуша сырокопчёная',
        '2023-01-15',
        '2033-01-15',
        1,
        1
    )
    """;
    await using var cmd = new NpgsqlCommand(sql, conn, transaction);
    await cmd.ExecuteNonQueryAsync();
    Console.WriteLine("F1 Insert done");  

    await transaction.CommitAsync();
    Console.WriteLine("F1 Commit done");

    canTryAgain = true;
});

await Task.WhenAll(insert, read);
```

![фото](transactions_screenshots/7_1.png)

8. SERIALIZABLE - Фантомное чтение

8.1 Попытка два раза обновить пользователя

```csharp

using Npgsql;

string ConnectionString = "Host=localhost;Username=postgres;Password=9492;Database=PapersPlease";

bool canStart = false;
bool canCommit = false;
bool canCommit2 = false;

var insert = Task.Run(async () =>
{
    try
    {
        await using var conn = new NpgsqlConnection(ConnectionString);
        await conn.OpenAsync();

        await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.Serializable);

        var sql =
        """
        UPDATE identity.passport
        SET
            fullName = 'Евгений Твёрдо'
        WHERE fullName = 'Евгений Жидко';
        """;
        await using var cmd = new NpgsqlCommand(sql, conn, transaction);
        await cmd.ExecuteNonQueryAsync();
        Console.WriteLine("F1 Update");

        canStart = true;

        while (!canCommit)
        {
            await Task.Delay(1000);
        }

        Console.WriteLine("T1 Commit");
        await transaction.CommitAsync();

        canCommit2 = true;
    }
    catch (Exception e)
    {
        Console.WriteLine(e.Message);
    }
});

var read = Task.Run(async () =>
{
    try
    {
        await using var conn = new NpgsqlConnection(ConnectionString);
        await conn.OpenAsync();

        await using var transaction = await conn.BeginTransactionAsync(System.Data.IsolationLevel.Serializable);

        while (!canStart)
        {
            await Task.Delay(1000);
        }

        var sql =
        """
        UPDATE identity.passport
        SET
            fullName = 'Евгений Твёрдо'
        WHERE fullName = 'Евгений Жидко';
        """;
        await using var cmd = new NpgsqlCommand(sql, conn, transaction);
        await cmd.ExecuteNonQueryAsync();
        Console.WriteLine("F2 Update");

        canCommit = true;

        while (!canCommit2)
        {
            await Task.Delay(1000);
        }

        await transaction.CommitAsync();
        Console.WriteLine("F2 Commit");
    }
    catch (Exception e)
    {
        Console.WriteLine(e.Message);
    }
});

await Task.WhenAll(insert, read);
```

Исполнение умирает как только начинается второй update
В консоли: F1 Update, и всё

