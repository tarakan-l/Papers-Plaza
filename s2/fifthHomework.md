1. Checking WAL journal and LSN in it:

<img width="751" height="292" alt="image" src="https://github.com/user-attachments/assets/f37ae312-336b-43a7-a5b6-b9826b421b11" />

2. Checking metadatas and etc via script after quick insert:
```sql
INSERT INTO identity.country (name, code) VALUES ('WAL_TEST', 'WT');
```

<img width="874" height="282" alt="image" src="https://github.com/user-attachments/assets/61c20a31-15be-455f-b140-32fe3261bece" />

3. Checking transaction
```sql
SELECT pg_current_wal_lsn() AS lsn_start; // just remember this lol / 0/57D6E688

//then
BEGIN;
  UPDATE identity.country SET name = 'WAL_TEST_TX' WHERE id = 1;
  
  SELECT pg_current_wal_lsn() AS lsn_after_update; // 0/57D70CF0

//then
COMMIT; 

SELECT pg_current_wal_lsn() AS lsn_final; 0/57D70E98
```

4. Checking massive operation (using LSN that I wrote before operation)
```sql
UPDATE identity.passport 
SET metadata = metadata || '{"wal_check": "done"}';


SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), '0/4C204490') / 1024 / 1024 AS wal_mb_generated;
```

<img width="962" height="239" alt="image" src="https://github.com/user-attachments/assets/2435c80b-4450-485b-a57b-9ff6e3c538a2" />

5. Creating empty db:
```bash
docker exec -it postgres_boss psql -U postgres -c "CREATE DATABASE dbtest_new;"
```

6. Creating dump:
```bash
docker exec -t postgres_boss pg_dump -U postgres dbtest > full_dump.sql
```

7. Loading dump in:
```sql
docker exec -i postgres_boss psql -U postgres dbtest_new < full_dump.sql
```

Done! 
![Uploading image.png…]()


