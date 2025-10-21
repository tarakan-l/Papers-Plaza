1. COUNT()

1.1 Получить количество стран, жители которых могут приехать в Россию
```sql
SELECT COUNT(*) 
FROM identity.citizenEntryPermission
WHERE toId = 1;
```
![фото](aggregate_group_screenshots/1_1.png)


2. SUM()

2.1 Получить сумму Id всех стран, жители которых могут приехать в Россию
```sql
SELECT SUM(fromId)
FROM identity.citizenEntryPermission
WHERE toId = 1;
```
![фото](aggregate_group_screenshots/2_1.png)


3. AVG()

3.1 Получить среднее Id всех стран, жители которых могут приехать в Китай
```sql
SELECT AVG(fromId)
FROM identity.citizenEntryPermission
WHERE toId = 4;
```
![фото](aggregate_group_screenshots/3_1.png)


4. MIN()

4.1 Получить дату выпуска самого старого паспорта
```sql
SELECT MIN(issueDate)
FROM identity.passport;
```
![фото](aggregate_group_screenshots/4_1.png)


5. MAX()

5.1 Получить дату, к которой у всех паспортов истечёт срок годности
```sql
SELECT MAX(validUntil)
FROM identity.passport;
```
![фото](aggregate_group_screenshots/5_1.png)

6. STRING_AGG()

6.1 Получить из списка паспортов все имена приезжих, помеченные как просроченные, если паспорт недействителен, иначе как действительные
```sql
SELECT STRING_AGG(country.name, ', ') as names
FROM identity.citizenEntryPermission
JOIN identity.country on country.id = citizenEntryPermission.fromId
WHERE toId = 1;
```
![фото](aggregate_group_screenshots/6_1.png)

7. GROUP BY

7.1 Получить паспорт пользователя с именем 'Джеки Чан'
```sql
SELECT *
FROM identity.passport
WHERE fullName = 'Джеки Чан';
```
![фото](aggregate_group_screenshots/7_1.png)

8. HAVING

8.1 Получить паспорта пользователей, чьё ФИО больше 10 букв и у которых есть биометрия
```sql
SELECT *
FROM identity.passport
WHERE LENGTH(fullname) > 10 AND biometry IS NOT NULL;
```
![фото](aggregate_group_screenshots/8_1.png)

9. GROUPING SETS

9.1 Получить ФИО и ID пользователей с паспортами, чьё ФИО длиной от 3 до 10 букв
```sql
SELECT id, fullname
FROM identity.passport
WHERE LENGTH(fullname) BETWEEN 3 AND 10;
```
![фото](aggregate_group_screenshots/9_1.png)

10. ROLLUP

10.1 Получить ФИО и ID пользователей с паспортами из Китая(4) и России(1)
```sql
SELECT id, fullname, country
FROM identity.passport
WHERE country IN (1, 4);
```
![фото](aggregate_group_screenshots/10_1.png)

11. CUBE

11.1 Получить ФИО пользователей с паспортами в лексикографическом порядке
```sql
SELECT fullname
FROM identity.passport
ORDER BY fullname;
```
![фото](aggregate_group_screenshots/11_1.png)

12. SELECT + FROM + WHERE + GROUP BY + HAVING + ORDER BY

12.1 Получить ФИО пользователей с паспортами в лексикографическом порядке
```sql
SELECT fullname
FROM identity.passport
ORDER BY fullname;
```
![фото](aggregate_group_screenshots/11_1.png)