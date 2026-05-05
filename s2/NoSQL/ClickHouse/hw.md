1. Startup
```bash
docker run -d --name clickhouse-server --ulimit nofile=262144:262144 -p 8123:8123 -p 9000:9000 clickhouse/clickhouse-server
```

2. Getting into client
```bash
docker exec -it clickhouse-server clickhouse-client
```

3. Creating table
```sql
CREATE TABLE trips (
    trip_id UInt32,
    start_time DateTime,
    end_time DateTime,
    distance_km Float32,
    city String
) 
ENGINE = MergeTree() 
ORDER BY (city, start_time);
```

4. Filling data
```sql
INSERT INTO trips
SELECT
    number AS trip_id,
    now() - rand() % 1000000 AS start_time,
    start_time + (rand() % 3600) AS end_time,
    (rand() % 1000) / 10.0 AS distance_km,
    ['Moscow', 'Minsk', 'Almaty', 'Tbilisi', 'Yerevan'][rand() % 5 + 1] AS city
FROM numbers(1000000);
```

5. Analytic
```sql
SELECT
    city,
    avg(distance_km) AS avg_distance,
    count() AS trip_count,
    max(dateDiff('second', start_time, end_time)) AS max_duration_sec
FROM trips
GROUP BY city;
```

<img width="497" height="275" alt="image" src="https://github.com/user-attachments/assets/1465f73d-3a9f-49ea-96c6-418b6f238da6" />


