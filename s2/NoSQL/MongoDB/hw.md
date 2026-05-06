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

![Uploading image.png…]()

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

![Uploading image.png…]()

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
![Uploading image.png…]()
