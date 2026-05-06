1. Getting into browser UI 
2. Pasting in start blocks
```Neo4j
// 1. Создаем категории и статьи
CREATE (c1:Category {name: "Tech"}), (c2:Category {name: "Science"}), (c3:Category {name: "Art"})
CREATE (a1:Article {title: "AI in 2024"}), (a2:Article {title: "Quantum Physics"}), (a3:Article {title: "Modern Painting"}), (a4:Article {title: "Docker Tips"})

// Связываем статьи с категориями
MATCH (a1:Article {title: "AI in 2024"}), (c1:Category {name: "Tech"}) CREATE (a1)-[:IN_CATEGORY]->(c1)
MATCH (a4:Article {title: "Docker Tips"}), (c1:Category {name: "Tech"}) CREATE (a4)-[:IN_CATEGORY]->(c1)
MATCH (a2:Article {title: "Quantum Physics"}), (c2:Category {name: "Science"}) CREATE (a2)-[:IN_CATEGORY]->(c2)
MATCH (a3:Article {title: "Modern Painting"}), (c3:Category {name: "Art"}) CREATE (a3)-[:IN_CATEGORY]->(c3);

// 2. Добавляем читателя и связи
CREATE (u:User {name: "Alex"})
WITH u
MATCH (a:Article) WHERE a.title IN ["AI in 2024", "Docker Tips", "Quantum Physics"]
CREATE (u)-[:READ]->(a);
```

<img width="1867" height="289" alt="image" src="https://github.com/user-attachments/assets/a03c3539-e6ef-461e-829b-d74539ae9beb" />


3. Show all users
```
MATCH (n) RETURN n
```

<img width="1421" height="631" alt="image" src="https://github.com/user-attachments/assets/4c778f87-1a45-4bab-bdae-32e4d0d70329" />

4. Finding categories that Alex reading

<img width="1166" height="261" alt="image" src="https://github.com/user-attachments/assets/7228e415-c4cc-448a-9d22-1943ed38144d" />

5. Alex was the most intense reader...

<img width="1151" height="240" alt="image" src="https://github.com/user-attachments/assets/a28b2e96-036c-4c97-9d87-574dda747d02" />

6. Collabarate filter

<img width="1317" height="278" alt="image" src="https://github.com/user-attachments/assets/7590c113-64a6-451f-8698-41887c091d2b" />

7. Recommendations by graph

<img width="1286" height="100" alt="image" src="https://github.com/user-attachments/assets/b0c27d7c-4ef2-49dd-89a2-0e70423dbd97" />

*womp womp* no recommendations


