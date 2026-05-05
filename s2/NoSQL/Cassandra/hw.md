1. Only two nodes got up
```sql
CREATE KEYSPACE hw1 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2};

USE hw1;


CREATE TABLE orders_by_id (order_id int PRIMARY KEY, customer_name text, amount decimal, city text);
CREATE TABLE orders_by_city (city text, order_id int, customer_name text, amount decimal, PRIMARY KEY (city, order_id));


INSERT INTO orders_by_id (order_id, customer_name, amount, city) VALUES (1, 'Ivan', 500, 'Moscow');
INSERT INTO orders_by_city (city, order_id, customer_name, amount) VALUES ('Moscow', 1, 'Ivan', 500);


SELECT * FROM orders_by_id WHERE order_id = 1;

SELECT * FROM orders_by_id WHERE customer_name = 'Ivan';

UPDATE orders_by_id SET amount = 700 WHERE order_id = 1;

DELETE FROM orders_by_id WHERE order_id = 1;
```

catching up error:
```bash
cqlsh:hw1> SELECT * FROM orders_by_id WHERE customer_name = 'Ivan';
InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and thus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
cqlsh:hw1> 
```
