1. Starting simplfied ver
```
 docker run -d --name elasticsearch -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.12.0
```

2. Putting in document
```bash
curl -X PUT "localhost:9200/products"
```

3. Creating document with auto-id
```bash
curl -X POST "localhost:9200/products/_doc/" -H 'Content-Type: application/json' -d'
{"name": "Laptop", "price": 1000, "category": "electronics"} '
```

4. Add with assigned id
```bash
curl -X PUT "localhost:9200/products/_doc/100" -H 'Content-Type: application/json' -d'
{"name": "Smartphone", "price": 500, "category": "electronics"} '
```

5. Post update
```bash
curl -X POST "localhost:9200/products/_update/100" -H 'Content-Type: application/json' -d'
{"doc": {"price": 450}} '
```

6. Delete document
```bash
curl -X POST "localhost:9200/products/_update/100" -H 'Content-Type: application/json' -d'
{"doc": {"price": 450}} '
```

<img width="1326" height="435" alt="image" src="https://github.com/user-attachments/assets/79f218d3-df8c-4cd9-808f-a7a14c2bb93f" />

7. Some searchs
```bash
curl -X POST "localhost:9200/products/_doc/" -H 'Content-Type: application/json' -d' {"name": "Gaming Mouse", "price": 50, "category": "accessories"} '
curl -X POST "localhost:9200/products/_doc/" -H 'Content-Type: application/json' -d' {"name": "Mechanical Keyboard", "price": 120, "category": "accessories"} '
```

8. Match
```bash
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{ "query": { "match": { "name": "gaming" } } }'
```
![Uploading image.png…]()

9. Term
```bash
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{ "query": { "term": { "category.keyword": "accessories" } } }'
```

10. Range
```bash
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{ "query": { "range": { "price": { "gte": 100, "lte": 1500 } } } }'
```

11. Bool
```bash
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [ { "match": { "category": "electronics" } } ],
      "filter": [ { "range": { "price": { "lt": 1000 } } } ]
    }
  }
}'
```


