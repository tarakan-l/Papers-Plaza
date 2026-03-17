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
<img width="457" height="377" alt="image" src="https://github.com/user-attachments/assets/2d3f9aa2-aa61-4e54-a84f-f867b1a44499" />

8. Creating a dump with single table: 
```
docker exec -t postgres_boss pg_dump -U postgres -t identity.passport dbtest > passport_table.sql
```

9. Creating seeded data
```sql
INSERT INTO Items.LuggageItemType (id, itemName) 
VALUES (10, 'Musical Instrument'), (11, 'Sport Equipment')
ON CONFLICT (id) DO UPDATE SET itemName = EXCLUDED.itemName;
```
<img width="308" height="498" alt="image" src="https://github.com/user-attachments/assets/f21452e1-817a-4d4a-95bf-f9c701012395" />



10. Adding with seed if not enlisted
```sql
INSERT INTO papers.vaccine (name)
SELECT 'Experimental Vaccine'
WHERE NOT EXISTS (
    SELECT 1 FROM papers.vaccine WHERE name = 'Experimental Vaccine'
);
```
<img width="1498" height="731" alt="image" src="https://github.com/user-attachments/assets/72bd185a-0731-4f8b-98e8-bc435023fd7f" />


11. Adding if unique
```sql
INSERT INTO identity.country (name, code)
SELECT 'Newland', 'NL'
WHERE 'NL' NOT IN (SELECT code FROM identity.country);

```
<img width="1490" height="715" alt="image" src="https://github.com/user-attachments/assets/9f445450-86dc-4d9c-988c-f5f6f8102370" />


12. Adding mass
```sql
INSERT INTO identity.country (name, code)
SELECT 'Country_' || i, (i % 99)::text -- Будут коды '1', '2' ... '98'
FROM generate_series(500, 600) AS s(i)
ON CONFLICT DO NOTHING;
```


