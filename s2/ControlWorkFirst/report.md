1. Задание 1. Оптимизация простого запроса

Выполняем скриптик
```sql
EXPLAIN ANALYZE
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

<img width="1039" height="191" alt="image" src="https://github.com/user-attachments/assets/040a185b-6cb6-4c1c-800a-9ac86aa0b9e0" />

Получился Seq Scan, почему не:
IndexScan - запрос вернул слишком большую таблицу и индексы были менее эффективны чем SeqScan
HashScan - вообще тут не прошел бы, у нас операции сравнения, а не равенства


Создали b-tree index, теперь у нас выполняется через Bitmap scan, т.к. он просто размапил временные интервалы
Analyze нужен т.к. он обновит в pg_stats наилучший метод поиска а потом он и будет использоваться

```sql
CREATE INDEX balbes ON public.store_checks USING btree (sold_at);
```
```text
Bitmap Heap Scan on store_checks  (cost=21.66..726.44 rows=1 width=26) (actual time=1.217..1.219 rows=3 loops=1)
```

2. Задание 2. Анализ и улучшение JOIN-запроса

До изменений

<img width="1020" height="708" alt="image" src="https://github.com/user-attachments/assets/75007cac-9f44-4ad2-925a-967a306534e3" />

Использован тип HashJoin

Использован он тому что тут простое сравнение индексов:
```sql
v.member_id = m.id
```

Тут наверное будет бесполезен IndexOnly, Index т.к. они по сути не так сильно оптимизированы для сравнения по '='

Лучше использовать GiN, GiST индексацию,
Запрос улучшился (dude trust me, у меня просто картинка не грузится) за счет того что произошел уже Merge Join

Преоблодание Shared-hit мы брали часть данных из кеша, а read - брали сразу с диска (дороже)

3. Задание 3. MVCC и очистка

UPDATE не просто "перезаписывает строку" он делает DELETE + INSERT, то есть:
При Update у нас создалась новая строка с xmin = xmin старой строки, 
у старой строки xmax = id транзакции update, а ctid - показывает (номер страницы, номер строки) где лежит строка, для новой строки в update он будет построен по цепочке, ссылаясь со старой строки на новую теперь

- VACUUM - Очищает таблицу, убирая мертвые кортежи и самое главное вычищая ссылки индексов на мертвые объекты
- autovacuum - автоматический механизм вакуумирования
- VACUUM FULL - Полностью пересобирает таблицу, БЛОКИРУЕТ ЕЁ НА ВРЕМЯ ОПЕРАЦИИ ДЛЯ ЛЮБЫХ ОПЕРАЦИЙ, отдает свободное место обратно на диск

4. Задание 4. Блокировки строк

1. Опишите, что происходит с DELETE и UPDATE в сессии B в двух экспериментах. - В первом случае Delete залочился и пока не был сделан Rollback он не executed, во втором кейсе у нас Update - произошел но не затронул строку, но и не был залочен процессом, возвращая Update - 0
2. Объясните, чем FOR KEY SHARE отличается от FOR NO KEY UPDATE по смыслу и по силе блокировки: For key share - позволяет смотреть и обновлять на строку которая взята в транзакции, no key update позволяет её тоже смотреть, но при изменении ничего не произойдет
3. Укажите, почему обычный SELECT без FOR KEY SHARE/FOR NO KEY UPDATE ведет себя иначе - 
4. Кратко поясните, где в прикладных сценариях может использоваться FOR NO KEY UPDATE -

5. Задание 5. Секционирование и partition pruning

```sql
CREATE TABLE shipment_stats (
    region_code TEXT NOT NULL,
    shipped_on DATE NOT NULL,
    packages INTEGER NOT NULL,
    avg_weight NUMERIC(8,2)
) PARTITION BY LIST (region_code);

CREATE TABLE shipment_stats_north 
    PARTITION OF shipment_stats FOR VALUES IN ('north');

CREATE TABLE shipment_stats_south 
    PARTITION OF shipment_stats FOR VALUES IN ('south');

CREATE TABLE shipment_stats_west 
    PARTITION OF shipment_stats FOR VALUES IN ('west');

CREATE TABLE shipment_stats_default 
    PARTITION OF shipment_stats DEFAULT;
```

1. Для каждого запроса укажите, есть ли partition pruning - для первого нет, он в одной партиции, для второй - да
2. Для каждого запроса укажите, сколько секций участвует в плане - в первом одна секция, во втором - все 4 секции
3. Объясните, почему в одном случае планировщик может отсечь секции, а в другом — нет
4. Ответьте, связан ли pruning напрямую с наличием обычного индекса - нет, не связан
5. Кратко объясните, зачем в этом задании нужна секция DEFAULT - чтобы данные не попадающие под фильтры партиции отправлялись именно туда



