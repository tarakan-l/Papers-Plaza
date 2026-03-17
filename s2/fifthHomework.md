1. Checking WAL journal and LSN in it:

<img width="751" height="292" alt="image" src="https://github.com/user-attachments/assets/f37ae312-336b-43a7-a5b6-b9826b421b11" />

2. Checking metadatas and etc via script after quick insert:
```sql
INSERT INTO identity.country (name, code) VALUES ('WAL_TEST', 'WT');
```

![Uploading image.png…]()

4. Checking massive operation (using LSN that I wrote before operation)
```sql
UPDATE identity.passport 
SET metadata = metadata || '{"wal_check": "done"}';


SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), '0/4C204490') / 1024 / 1024 AS wal_mb_generated;
```

![Uploading image.png…]()
