1. Выборка всех данных из таблицы

1.1 Получить список всех стран (Id + Название)
```sql
SELECT * FROM identity.country;
```
![фото](select_join_screenshots/1_1.png)

1.2 Получить все данные таблицы криминальных случаев
```sql
SELECT * FROM criminal."case";
```
<img width="363" height="136" alt="image" src="https://github.com/user-attachments/assets/18430a60-a024-4997-9495-757616bf9bd3" />



2. Выборка отдельных столбцов

2.1 Получить названия всех стран
```sql
SELECT name FROM identity.country;
```
![фото](select_join_screenshots/2_1.png)


3. Присвоение новых имен столбцам при формировании выборки

3.1 Получить из списка паспортов все имена приезжих с их страной
```sql
SELECT fullname, country as from
FROM identity.passport;
```
![фото](select_join_screenshots/3_1.png)


4. Выборка данных с созданием вычисляемого столбца

4.1 Получить из списка паспортов все имена приезжих с данными о валидности паспорта
```sql
SELECT fullName,
    validUntil > CURRENT_DATE AS is_valid
FROM identity.passport;
```
![фото](select_join_screenshots/4_1.png)


5. Выборка данных, вычисляемые столбцы, математические функции

5.1 Получить из списка паспортов все имена приезжих с квадратным корнем идентификатора (зачем? неважно)
```sql
SELECT fullName, sqrt(id) as square_root 
FROM identity.passport;
```
![фото](select_join_screenshots/5_1.png)

6. Выборка данных, вычисляемые столбцы, логические функции

6.1 Получить из списка паспортов все имена приезжих, помеченные как просроченные, если паспорт недействителен, иначе как действительные
```sql
SELECT fullName,
CASE
    WHEN validUntil > CURRENT_DATE
    THEN '[действительно]'
    ELSE '[просрочено]'
END AS validTag
FROM identity.passport;
```
![фото](select_join_screenshots/6_1.png)

7. Выборка данных по условию

7.1 Получить паспорт пользователя с именем 'Джеки Чан'
```sql
SELECT *
FROM identity.passport
WHERE fullName = 'Джеки Чан';
```
![фото](select_join_screenshots/7_1.png)

8. Выборка данных, логические операции

8.1 Получить паспорта пользователей, чьё ФИО больше 10 букв и у которых есть биометрия
```sql
SELECT *
FROM identity.passport
WHERE LENGTH(fullname) > 10 AND biometry IS NOT NULL;
```
![фото](select_join_screenshots/8_1.png)

9. Выборка данных, оператор BETWEEN

9.1 Получить ФИО и ID пользователей с паспортами, чьё ФИО длиной от 3 до 10 букв
```sql
SELECT id, fullname
FROM identity.passport
WHERE LENGTH(fullname) BETWEEN 3 AND 10;
```
![фото](select_join_screenshots/9_1.png)

10. Выборка данных, оператор IN

10.1 Получить ФИО и ID пользователей с паспортами из Китая(4) и России(1)
```sql
SELECT id, fullname, country
FROM identity.passport
WHERE country IN (1, 4);
```
![фото](select_join_screenshots/10_1.png)

11. Выборка данных с сортировкой

11.1 Получить ФИО пользователей с паспортами в лексикографическом порядке
```sql
SELECT fullname
FROM identity.passport
ORDER BY fullname;
```
![фото](select_join_screenshots/11_1.png)

12. Выборка данных, оператор LIKE

12.1 Получить ФИО пользователей с паспортами, у которых в ФИО присутствует буква Д
```sql
SELECT fullname
FROM identity.passport
WHERE fullname LIKE '%Д%';
```
![фото](select_join_screenshots/12_1.png)

13. Выбор уникальных элементов столбца

13.1 Получить ID стран, куда можно въезжать иностранцам
```sql
SELECT DISTINCT toId
FROM identity.citizenEntryPermission;
```
![фото](select_join_screenshots/13_1.png)

14. Выбор ограниченного количества возвращаемых строк.

14.1 Получить какую-то одну страну, в которые можно въезжать гражданам США
```sql
SELECT DISTINCT toId
FROM identity.citizenEntryPermission
WHERE fromID = 2
LIMIT 1;
```
![фото](select_join_screenshots/14_1.png)

15. Соединение INNER JOIN

15.1 Получить ФИО пользователей с паспортами вместе с названиями стран, откуда они
```sql
SELECT p.fullname, c.name
FROM identity.passport p
INNER JOIN identity.country c ON p.country = c.id;
```
![фото](select_join_screenshots/15_1.png)

16. Внешнее соединение LEFT OUTER JOIN

16.1 Получить список пользователей и, при наличии удостоверения дипломата, дату истечения его срока
```sql
SELECT p.fullname, d.validUntil
FROM identity.passport p
LEFT JOIN papers.diplomatCertificate d ON p.fullName = d.fullName;
```
![фото](select_join_screenshots/16_1.png)

17. Внешнее соединение RIGHT OUTER JOIN

17.1 Получить все удостоверения дипломата и, при наличии данных, дату истечения срока действия паспортов дипломатов
```sql
SELECT d.fullname, p.validUntil
FROM identity.passport p
RIGHT JOIN papers.diplomatCertificate d ON p.fullName = d.fullName;
```
![фото](select_join_screenshots/17_1.png)

18. Перекрестное соединение CROSS JOIN

18.1 Получить все возможные пары стран (ограничиться 10-ю)
```sql
SELECT c1.name, c2.name
FROM identity.country c1, identity.country c2
LIMIT 10;
```
![фото](select_join_screenshots/18_1.png)

19. Запросы на выборку из нескольких таблиц

19.1 Получить все записи о том, из какой страны в какую можно въезжать, но вместо ID их названия
```sql
SELECT c1.name as from, c2.name as to
FROM identity.citizenEntryPermission perm
INNER JOIN identity.country c1 ON perm.fromId = c1.id
INNER JOIN identity.country c2 ON perm.toId = c2.id;
```
![фото](select_join_screenshots/19_1.png)
