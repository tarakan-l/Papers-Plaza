0. Setted up docker
1. Setted up bucket via docker-compose.yml
2. Creating data
```bash
# Запись для room1
curl -i -X POST "http://localhost:8086/api/v2/write?org=myorg&bucket=mydb&precision=s" \
  --header "Authorization: Token my-super-secret-token" \
  --data-raw "temperature,location=room1 value=23.5"

# Запись для room2
curl -i -X POST "http://localhost:8086/api/v2/write?org=myorg&bucket=mydb&precision=s" \
  --header "Authorization: Token my-super-secret-token" \
  --data-raw "temperature,location=room2 value=21.0"

# Еще одна запись для room1 (чуть позже)
curl -i -X POST "http://localhost:8086/api/v2/write?org=myorg&bucket=mydb&precision=s" \
  --header "Authorization: Token my-super-secret-token" \
  --data-raw "temperature,location=room1 value=24.2"
```
<img width="300" height="259" alt="image" src="https://github.com/user-attachments/assets/79d4e9ee-a3d2-443d-98b8-ae62cf43ef69" />

3. Select
```bash
curl -i -X POST "http://localhost:8086/api/v2/query?org=myorg" \
  --header "Authorization: Token my-super-secret-token" \
  --header "Content-Type: application/vnd.flux" \
  --data 'from(bucket: "mydb") |> range(start: -5m) |> filter(fn: (r) => r._measurement == "temperature")'
```

<img width="1014" height="232" alt="image" src="https://github.com/user-attachments/assets/406d0112-7463-4f52-ad38-6e5ac51d8fcd" />

4. Executing sql
```SQL
curl -G "http://localhost:8086/query" \
  --header "Authorization: Token my-super-secret-token" \
  --data-urlencode "db=mydb" \
  --data-urlencode "q=SELECT location, AVG(value) FROM temperature WHERE time >= now() - 5m GROUP BY location"
```

![Uploading image.png…]()




