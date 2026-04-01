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

```sql
CREATE INDEX balbes ON public.store_checks USING btree (sold_at);
```
```text
Bitmap Heap Scan on store_checks  (cost=21.66..726.44 rows=1 width=26) (actual time=1.217..1.219 rows=3 loops=1)
```

2. Задание 2. Анализ и улучшение JOIN-запроса

До изменений

![Uploading image.png…]()

