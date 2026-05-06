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

3. El stupid el me inserted second book, so in search two books
```MongoDB
db.books.find({ available: true });
```

<img width="525" height="404" alt="image" src="https://github.com/user-attachments/assets/289d8f68-64a0-4b9f-9d63-77e0b34a2e41" />


4. Inserting lot o books
```MongoDB
db.books.insertMany([
  {
    title: "Refactoring",
    genre: "programming",
    price: 55.0,
    available: true,
    tags: ["software", "design"],
    author: { name: "Martin Fowler", country: "UK" }
  },
  {
    title: "The Hobbit",
    genre: "fantasy",
    price: 20.0,
    available: false,
    tags: ["adventure", "classic"],
    author: { name: "J.R.R. Tolkien", country: "South Africa" }
  },
  {
    title: "Deep Learning",
    genre: "programming",
    price: 80.0,
    available: true,
    tags: ["AI", "math"],
    author: { name: "Ian Goodfellow", country: "Canada" }
  },
  {
    title: "Dune",
    genre: "sci-fi",
    price: 25.0,
    available: true,
    tags: ["space", "epic"],
    author: { name: "Frank Herbert", country: "USA" }
  }
]);
```

<img width="398" height="162" alt="image" src="https://github.com/user-attachments/assets/b26bb3cc-f66c-43a4-8ef3-514796fa088d" />


5. Sophisticated find

```MongoDB
db.books.find(
  { 
    genre: "programming", 
    price: { $gt: 50 }, 
    available: true 
  },
  { title: 1, price: 1, _id: 0 }
);
```

<img width="352" height="239" alt="image" src="https://github.com/user-attachments/assets/99f37270-bfc5-41d8-9345-fa12822d907a" />

