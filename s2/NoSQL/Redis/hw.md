1. Get/INCR
```bash
 INCR article:10:views
 INCR article:10:views
 INCR article:10:views
 GET article:10:views
```

<img width="316" height="153" alt="image" src="https://github.com/user-attachments/assets/19b69ca3-04a4-4476-967d-d95688c9c628" />

(6 times cuz I executed incr twice)

2. Rating
```bash
ZADD top_articles 100 "article:1"
ZADD top_articles 250 "article:2"
ZADD top_articles 50 "article:3"
ZADD top_articles 180 "article:4"

ZREVRANGE top_articles 0 2

ZREVRANGE top_articles 0 2 WITHSCORES

ZADD top_articles 1000 "article:3"

ZREVRANGE top_articles 0 2 WITHSCORES
```

<img width="453" height="574" alt="image" src="https://github.com/user-attachments/assets/33c8493a-110b-478d-9a65-c0108da6ce88" />

4. Rate limiting
```bash
INCR user:777:likes

EXPIRE user:777:likes 60

INCR user:777:likes
INCR user:777:likes

GET user:777:likes
```

<img width="339" height="270" alt="image" src="https://github.com/user-attachments/assets/c8030b6e-0df5-4eb6-9a20-8c47d2d77276" />

dead

<img width="329" height="111" alt="image" src="https://github.com/user-attachments/assets/1532535d-7bff-4246-8348-4c2dd82b1e03" />

