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
1. 
