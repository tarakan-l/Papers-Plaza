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

