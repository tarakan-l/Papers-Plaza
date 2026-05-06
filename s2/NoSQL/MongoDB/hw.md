1. Entering in UI
```bash
docker exec -it mongodb mongosh
```

2. Library auto-creating with first insert
```MongoDB
use library;

db.books.insertOne({
  title: "Clean Code",
  genre: "programming",
  price: 45.0,
  available: true,
  tags: ["software", "best practices"],
  author: {
    name: "Robert C. Martin",
    country: "USA"
  }
});
```

<img width="358" height="297" alt="image" src="https://github.com/user-attachments/assets/5712f439-1a48-481f-8817-994a5bde29f4" />

3. 
