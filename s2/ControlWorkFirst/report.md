1. Задание 1. Оптимизация простого запроса

Выполняем скриптик
```sql
EXPLAIN ANALYZE
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

<img width="1039" height="191" alt="image" src="https://github.com/user-attachments/assets/040a185b-6cb6-4c1c-800a-9ac86aa0b9e0" />

Получился Seq Scan, почему не:
IndexScan - запрос вернул слишком большую таблицу и индексы были менее эффективны чем SeqScan
HashScan - вообще тут не прошел бы, у нас операции сравнения, а не равенства

Создали b-tree index, теперь у нас выполняется через Bitmap scan, т.к. он просто размапил временные интервалы
Analyze нужен т.к. он обновит в pg_stats наилучший метод поиска а потом он и будет использоваться

![Uploading image.png…]()

