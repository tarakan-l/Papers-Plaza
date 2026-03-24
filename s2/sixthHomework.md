<img width="1732" height="700" alt="image" src="https://github.com/user-attachments/assets/b0ab0549-3cf0-4b94-bc07-53e7802e1a71" />


1. Created new role for replication:
```sql
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'pass';
```

2. Created two new replics:
```bash
  db_master:
    image: postgres:15
    container_name: postgres_master
    restart: always
    environment:
      POSTGRES_PASSWORD: 1234
      POSTGRES_DB: dbtest
    ports:
      - "5432:5432"
    command: |
      postgres 
      -c wal_level=replica 
      -c max_wal_senders=10 
      -c max_replication_slots=10 
      -c listen_addresses='*'
    volumes:
      - ./init-master.sh:/docker-entrypoint-initdb.d/init-master.sh
  
  db_replica_1:
    image: postgres:15
    container_name: postgres_replica_1
    depends_on:
      - db_master
    ports:
      - "5433:5432"
    environment:
      PGPASSWORD: pass
    entrypoint: [ "/bin/bash", "-c", "sleep 10 && rm -rf /var/lib/postgresql/data/* && pg_basebackup -h db_master -D /var/lib/postgresql/data -U replicator -P -R && docker-entrypoint.sh postgres" ]

  db_replica_2:
    image: postgres:15
    container_name: postgres_replica_2
    depends_on:
      - db_master
    ports:
      - "5434:5432"
    environment:
      PGPASSWORD: pass
    entrypoint: [ "/bin/bash", "-c", "sleep 15 && rm -rf /var/lib/postgresql/data/* && pg_basebackup -h db_master -D /var/lib/postgresql/data -U replicator -P -R && docker-entrypoint.sh postgres" ]

```

3. Теперь посмотрел physical streaming replication (выполнив на мастере):
```sql
SELECT application_name, state, sync_state, replay_lag 
FROM pg_stat_replication;
```

<img width="617" height="308" alt="image" src="https://github.com/user-attachments/assets/3a1fb3c9-76a3-4d17-8892-ac61a61e51f9" />

4. Вставил данные на мастере:

<img width="835" height="362" alt="image" src="https://github.com/user-attachments/assets/e11b4609-58a7-4d0e-89ed-a6073c501293" />

Проверил их на реплике:

<img width="602" height="373" alt="image" src="https://github.com/user-attachments/assets/4a38e624-7b39-4ec0-99c6-efb44ccbebce" />

5. El stupid попытка вставить на реплике (окончилась провалом):

<img width="681" height="285" alt="image" src="https://github.com/user-attachments/assets/f08045f6-c2c9-4ebf-a160-d6ff0e545e0d" />

6. Вставляем кучу данных
```sql
INSERT INTO replication_test (msg) 
SELECT 'bulk data ' || i FROM generate_series(1, 100000) s(i);
```

Смотрим на задержку (пока идёт вставка)

<img width="634" height="380" alt="image" src="https://github.com/user-attachments/assets/0d0947c5-841b-4c8b-b7c7-af82d8daf503" />

---LOGICAL REPLICATION---
1. Setting up replication level
```bash
-c wal_level=logical 
```

2. Creating publication on master
```sql
CREATE TABLE logical_demo (id int PRIMARY KEY, name text);
CREATE PUBLICATION my_publication FOR TABLE logical_demo;
```

3. Creating a subscription on replicas 
```sql
-- 1. Сначала на Реплике создаем такую же структуру
CREATE TABLE logical_demo (id int PRIMARY KEY, name text);

-- 2. Создаем подписку
CREATE SUBSCRIPTION my_subscription 
CONNECTION 'host=db_master port=5432 user=postgres password=1234 dbname=dbtest' 
PUBLICATION my_publication;
```

4. Data replicated (source - dude trust me)
```sql
INSERT INTO logical_test VALUES (777, 'Logical Success!');
```

and on replica:
```sql
SELECT * FROM logical_test;
```

<img width="297" height="411" alt="image" src="https://github.com/user-attachments/assets/3aa5e97d-7722-4c01-a705-5f9f9edaedf0" />

5. Trying to DDL

on master:
```sql
ALTER TABLE logical_test ADD COLUMN meta_data text;
```

checking on replica:
<img width="614" height="420" alt="image" src="https://github.com/user-attachments/assets/310f3563-ae2d-497c-87f6-84dc629444e0" />


6. Replica Identity 
Adding new table without primary key on main
```sql
CREATE TABLE identity_test (id int, val text);
ALTER PUBLICATION my_pub ADD TABLE identity_test;
```

subrscribing on it in replica, then adding some info to it, then trying to update:

<img width="944" height="261" alt="image" src="https://github.com/user-attachments/assets/6a2547f0-9498-4598-80b5-cf401c1b8106" />

7. Replication status

<img width="648" height="463" alt="image" src="https://github.com/user-attachments/assets/99d9ef11-d04d-416f-af0b-5b950bc60f67" />


