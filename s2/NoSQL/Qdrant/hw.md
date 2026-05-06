Executing whole task
```python
import os
from qdrant_client import QdrantClient
from qdrant_client.models import (
    VectorParams, Distance, PointStruct, Filter, 
    FieldCondition, MatchValue, Range, PayloadSchemaType
)
from sentence_transformers import SentenceTransformer

# 1. Setup Environment & Client
os.environ['no_proxy'] = '*'  # Fix for the 502/Proxy issues
model = SentenceTransformer('all-MiniLM-L6-v2') # Dimension 384
client = QdrantClient(host="127.0.0.1", port=6335, prefer_grpc=False)

COLLECTION_NAME = "articles"

# 2. Recreate Collection
if client.collection_exists(COLLECTION_NAME):
    client.delete_collection(COLLECTION_NAME)

client.create_collection(
    collection_name=COLLECTION_NAME,
    vectors_config=VectorParams(size=384, distance=Distance.COSINE),
)

# 3. Prepare and Insert Data
data = [
    {"title": "Marathon Basics", "content": "Learn how to start running and prepare for a marathon.", "author": "John Doe", "category": "sport", "rating": 4.5, "views": 1500, "published_at": "2024-02-01T10:00:00Z"},
    {"title": "AI in 2024", "content": "How neural networks and AI are changing the tech landscape.", "author": "Jane Smith", "category": "tech", "rating": 4.8, "views": 5000, "published_at": "2024-03-01T10:00:00Z"},
    {"title": "Football Finals", "content": "The championship match ended with a surprising victory.", "author": "Mike Ross", "category": "sport", "rating": 3.2, "views": 800, "published_at": "2023-11-20T10:00:00Z"},
    {"title": "Docker Secrets", "content": "Advanced tips for container optimization and security.", "author": "Alan Turing", "category": "tech", "rating": 4.1, "views": 2500, "published_at": "2024-01-15T10:00:00Z"},
    {"title": "Global Warming", "content": "Recent news about climate change and polar ice caps.", "author": "Eco Daily", "category": "news", "rating": 3.8, "views": 1200, "published_at": "2024-04-10T10:00:00Z"},
    {"title": "Tennis Pro", "content": "Improve your serve with these simple exercises.", "author": "Serena V.", "category": "sport", "rating": 4.0, "views": 600, "published_at": "2024-02-15T10:00:00Z"}
]

points = []
for i, item in enumerate(data):
    vector = model.encode(item["content"]).tolist()
    points.append(PointStruct(id=i, vector=vector, payload=item))

client.upsert(collection_name=COLLECTION_NAME, points=points)
print("Data inserted successfully.")

# 4. Search Queries

# Q1: Простой поиск (Бег и спорт)
res1 = client.search(
    collection_name=COLLECTION_NAME,
    query_vector=model.encode("бег и спорт").tolist(),
    limit=3
)
print("\n--- Q1: Simple Search ---")
for hit in res1: print(f"{hit.payload['title']} (Score: {hit.score:.3f})")

# Q2: Filter by Tech + Rating >= 4.0
res2 = client.search(
    collection_name=COLLECTION_NAME,
    query_vector=model.encode("technology trends").tolist(),
    query_filter=Filter(must=[
        FieldCondition(key="category", match=MatchValue(value="tech")),
        FieldCondition(key="rating", range=Range(gte=4.0))
    ]),
    limit=3
)
print("\n--- Q2: Tech & High Rating ---")
for hit in res2: print(f"{hit.payload['title']} (Rating: {hit.payload['rating']})")

# Q3: After 2024-01-01 + Views > 1000
res3 = client.search(
    collection_name=COLLECTION_NAME,
    query_vector=model.encode("popular news").tolist(),
    query_filter=Filter(must=[
        FieldCondition(key="published_at", range=Range(gt="2024-01-01T00:00:00Z")),
        FieldCondition(key="views", range=Range(gt=1000))
    ]),
    limit=3
)
print("\n--- Q3: Recent & Popular ---")
for hit in res3: print(f"{hit.payload['title']} (Views: {hit.payload['views']})")

# Q4: Complex Filter (Sport/Tech, Rating >= 3.5, Views 500-5000)
res4 = client.search(
    collection_name=COLLECTION_NAME,
    query_vector=model.encode("active high quality articles").tolist(),
    query_filter=Filter(
        must=[
            FieldCondition(key="rating", range=Range(gte=3.5)),
            FieldCondition(key="views", range=Range(gte=500, lte=5000))
        ],
        should=[
            FieldCondition(key="category", match=MatchValue(value="sport")),
            FieldCondition(key="category", match=MatchValue(value="tech"))
        ]
    ),
    limit=5
)
print("\n--- Q4: Complex Filter ---")
for hit in res4: print(f"{hit.payload['title']} (Cat: {hit.payload['category']}, Score: {hit.score:.3f})")

# 5. Create Payload Indexes
client.create_payload_index(COLLECTION_NAME, "category", PayloadSchemaType.KEYWORD)
client.create_payload_index(COLLECTION_NAME, "rating", PayloadSchemaType.FLOAT)
client.create_payload_index(COLLECTION_NAME, "published_at", PayloadSchemaType.DATETIME)
client.create_payload_index(COLLECTION_NAME, "views", PayloadSchemaType.INTEGER)
print("\nPayload indexes created successfully.")

```
