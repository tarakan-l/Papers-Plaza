1. Section

<img width="1026" height="355" alt="image" src="https://github.com/user-attachments/assets/0bda8b24-1939-4470-b7bb-7a7f4d456379" />

PostrgeSQL видит только orders_2024

2. List

<img width="892" height="382" alt="image" src="https://github.com/user-attachments/assets/b50a43c1-0636-4e83-9a00-1b6809647466" />


3. Hash

<img width="945" height="362" alt="image" src="https://github.com/user-attachments/assets/a29f7506-3b5d-4015-88c2-648ce4f081f1" />

4. Секционирование реплики

(dude trust me, image didnt upload)

реплика не знает о секционировании т.к. она отсылается байтами на родительскую таблицу - ей просто незачем это

5. Logic replication

```sql
CREATE PUBLICATION pub_parts FOR TABLE orders_range 
WITH (publish_via_partition_root = false);

CREATE PUBLICATION pub_root FOR TABLE orders_range 
WITH (publish_via_partition_root = true);
```

если с правами = true, то будем просто сразу в таблицу кидать, без секционки, удобно для аналитики чтобы держать большую таблицу вместо мелких секций

6. adding shards and router:

```sql
CREATE TABLE users_data (id int PRIMARY KEY, name text);
```

and router:
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

inserting data:
```sql
INSERT INTO users_sharded (id, name)
SELECT g, 'user_' || g
FROM generate_series(1, 10) g;
```

pulling data from shards:

<img width="663" height="392" alt="image" src="https://github.com/user-attachments/assets/e44f7860-70e2-4c65-a179-6e6a384fb0f3" />

pulling from single shard:

<img width="660" height="294" alt="image" src="https://github.com/user-attachments/assets/a53cdabe-8fdb-4774-85de-4c8945fe24b4" />

checking data on shards:

```sql
SELECT * FROM users_data;
```

<img width="359" height="525" alt="image" src="https://github.com/user-attachments/assets/0ec9fb13-0139-4174-9c15-9c62c36a4d51" />




