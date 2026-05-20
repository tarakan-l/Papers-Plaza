# OLAP & Data Infrastructure Report

## 1. Partitioning by RANGE

```sql
CREATE TABLE orders_range (id int, dt date, info text) PARTITION BY RANGE (dt);
CREATE TABLE orders_2023 PARTITION OF orders_range FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE orders_2024 PARTITION OF orders_range FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
ALTER TABLE orders_range ADD PRIMARY KEY (id, dt);

EXPLAIN SELECT * FROM orders_range WHERE dt = '2024-05-15' AND id = 10;
```

### Execution Plan Result:
```text
Index Only Scan using orders_range_2024_pkey on orders_range_2024 orders_range (cost=0.15..8.17 rows=1 width=8)
Index Cond: ((id = 10) AND (dt = '2024-05-15'::date))
```
* **Вывод**: Благодаря механизму Partition Pruning, PostgreSQL видит только секцию `orders_2024`. Остальные партиции полностью отсекаются на этапе планирования запроса.

---

## 2. Partitioning by LIST

```sql
CREATE TABLE users_list (id int, status text) PARTITION BY LIST (status);
CREATE TABLE users_active PARTITION OF users_list FOR VALUES IN ('active');
CREATE TABLE users_deleted PARTITION OF users_list FOR VALUES IN ('deleted');
ALTER TABLE users_list ADD PRIMARY KEY (id, status);

EXPLAIN SELECT * FROM users_list WHERE status = 'active';
```

### Execution Plan Result:
```text
Bitmap Heap Scan on users_active users_list (cost=13.68..23.15 rows=6 width=36)
Recheck Cond: (status = 'active'::text)
-> Bitmap Index Scan on users_active_pkey (cost=0.00..13.68 rows=6 width=0)
   Index Cond: (status = 'active'::text)
```
* **Вывод**: Запрос выполняется исключительно внутри изолированной таблицы-партиции `users_active`, сканируя только нужный статус.

---

## 3. Partitioning by HASH

```sql
CREATE TABLE logs_hash (id int, msg text) PARTITION BY HASH (id);
CREATE TABLE logs_0 PARTITION OF logs_hash FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE logs_1 PARTITION OF logs_hash FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE logs_2 PARTITION OF logs_hash FOR VALUES WITH (MODULUS 3, REMAINDER 2);
ALTER TABLE logs_hash ADD PRIMARY KEY (id);

EXPLAIN SELECT * FROM logs_hash WHERE id = 42;
```

### Execution Plan Result:
```text
Index Scan using logs_0_pkey on logs_0 logs_hash (cost=0.15..8.17 rows=1 width=36)
Index Cond: (id = 42)
```
* **Вывод**: Хэш-функция вычислила остаток деления для `id = 42`. План показывает точечное сканирование индекса только внутри целевой секции `logs_0`.

---

## 4. Секционирование реплики

* Физическая реплика (Streaming Replication) не знает и не думает о логическом секционировании, так как она оперирует на уровне низкоуровневых байт данных (WAL-логи) родительской таблицы. Ей просто незачем это знать — структура данных дублируется один в один на диске.

---

## 5. Logical Replication & Partitioning Options

```sql
CREATE PUBLICATION pub_parts FOR TABLE orders_range 
WITH (publish_via_partition_root = false);

CREATE PUBLICATION pub_root FOR TABLE orders_range 
WITH (publish_via_partition_root = true);
```
* **Вывод**: Если параметр `publish_via_partition_root = true`, то изменения дочерних партиций публикуются так, будто они происходят в корневой таблице. Это крайне удобно для DWH/OLAP аналитики, чтобы собирать и держать одну большую плоскую таблицу на стороне приемника вместо поддержки множества мелких секций.

---

## 6. Sharding via FDW (Foreign Data Wrappers)

### Infrastructure Configuration (Router setup):
```sql
CREATE EXTENSION postgres_fdw;

CREATE SERVER shard1_server FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'db_replica_1', dbname 'dbtest', port '5432');

CREATE SERVER shard2_server FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'db_replica_2', dbname 'dbtest', port '5432');

CREATE USER MAPPING FOR postgres SERVER shard1_server OPTIONS (user 'postgres', password '1234');
CREATE USER MAPPING FOR postgres SERVER shard2_server OPTIONS (user 'postgres', password '1234');

CREATE TABLE users_sharded (id int, name text) PARTITION BY HASH (id);

CREATE FOREIGN TABLE users_shard_0 PARTITION OF users_sharded 
FOR VALUES WITH (MODULUS 2, REMAINDER 0) SERVER shard1_server OPTIONS (table_name 'users_data');

CREATE FOREIGN TABLE users_shard_1 PARTITION OF users_sharded 
FOR VALUES WITH (MODULUS 2, REMAINDER 1) SERVER shard2_server OPTIONS (table_name 'users_data');
```

### Data Loading:
```sql
INSERT INTO users_sharded (id, name)
SELECT g, 'user_' || g
FROM generate_series(1, 10) g;
```

### Querying all shards (Full Scan):
```sql
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM users_sharded;
```
#### Execution Plan:
```text
Append
-> Foreign Scan on public.users_shard_0 users_sharded_1
   Output: users_sharded_1.id, users_sharded_1.name
   Remote SQL: SELECT id, name FROM public.users_data
-> Foreign Scan on public.users_shard_1 users_sharded_2
   Output: users_sharded_2.id, users_sharded_2.name
   Remote SQL: SELECT id, name FROM public.users_data
```

### Querying from single shard:
```sql
EXPLAIN (VERBOSE, COSTS OFF) SELECT * FROM users_sharded WHERE id = 1;
```
#### Execution Plan:
```text
Foreign Scan on public.users_shard_0 users_sharded
Output: users_sharded.id, users_sharded.name
Remote SQL: SELECT id, name FROM public.users_data WHERE ((id = 1))
```

### Verification on target shards:
```sql
SELECT * FROM users_data;
```
