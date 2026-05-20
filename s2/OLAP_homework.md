1. Аналитические вопросы по таможне

Выбрал 3 простых вопроса для анализа проходов границы:
- Какая динамика проходов по годам выдачи паспортов?
- Из каких стран чаще всего везут определенные типы вещей в багаже?
- Сколько преступников пытаются пройти границу с дипломатическим статусом и без?

2. Главный факт

fact_border_crossings (таблица фактов попыток пересечения границы)

3. Зерно факта

1 строка = 1 попытка въезда гражданина (Entrant) через КПП

4. Создание измерений и таблицы фактов (olap схема)

```sql
CREATE SCHEMA IF NOT EXISTS olap;

CREATE TABLE olap.dim_date (
    date_key INT PRIMARY KEY,
    date_actual DATE NOT NULL,
    day_num INT NOT NULL,
    month_num INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_num INT NOT NULL
);

CREATE TABLE olap.dim_entrant (
    passport_id INT PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL,
    countryName VARCHAR(20) NOT NULL,
    hasBiometry BOOLEAN NOT NULL,
    hasDiplomatStatus BOOLEAN NOT NULL
);

CREATE TABLE olap.dim_luggage_summary (
    luggage_id INT PRIMARY KEY,
    totalItemsCount INT NOT NULL,
    mainItemType VARCHAR(255)
);

CREATE TABLE olap.fact_border_crossings (
    id SERIAL PRIMARY KEY,
    passport_date_key INT REFERENCES olap.dim_date(date_key),
    entrant_id INT REFERENCES olap.dim_entrant(passport_id),
    luggage_id INT REFERENCES olap.dim_luggage_summary(luggage_id),
    hasWorkPermission BOOLEAN NOT NULL,
    hasVaccination BOOLEAN NOT NULL,
    isWantedCriminal BOOLEAN NOT NULL
);
```

5. Заполнение OLAP-таблиц из OLTP (наш простой ETL)

```sql
INSERT INTO olap.dim_date (date_key, date_actual, day_num, month_num, month_name, year_num)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT, datum,
    EXTRACT(DAY FROM datum), EXTRACT(MONTH FROM datum),
    TO_CHAR(datum, 'TMMonth'), EXTRACT(YEAR FROM datum)
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) datum;

INSERT INTO olap.dim_entrant (passport_id, fullName, countryName, hasBiometry, hasDiplomatStatus)
SELECT 
    p.id, p.fullName, c.name,
    (p.biometry IS NOT NULL), (e.diplomatCertificateId IS NOT NULL)
FROM People.Entrant e
JOIN identity.passport p ON e.passportId = p.id
JOIN identity.country c ON p.country = c.id;

INSERT INTO olap.dim_luggage_summary (luggage_id, totalItemsCount, mainItemType)
SELECT 
    l.id, COUNT(li.id), MAX(lit.itemName)
FROM Items.Luggage l
LEFT JOIN Items.LuggageItem li ON li.luggage_id = l.id
LEFT JOIN Items.LuggageItemType lit ON li.itemType_Id = lit.id
GROUP BY l.id;

INSERT INTO olap.fact_border_crossings (passport_date_key, entrant_id, luggage_id, hasWorkPermission, hasVaccination, isWantedCriminal)
SELECT 
    TO_CHAR(p.issueDate, 'YYYYMMDD')::INT,
    e.passportId,
    e.luggageId,
    (e.workPermissionId IS NOT NULL),
    (e.vaccinationCertificateId IS NOT NULL),
    CASE WHEN cr.crimeId IS NOT NULL THEN TRUE ELSE FALSE END
FROM People.Entrant e
JOIN identity.passport p ON e.passportId = p.id
LEFT JOIN Criminal.Record cr ON p.biometry = cr.biometryId;
```

6. Три аналитических запроса

Запрос 1: Смотрим сколько людей идет по годам паспортов и сколько из них в розыске
```sql
SELECT 
    d.year_num AS passport_year,
    COUNT(f.id) AS total_entrants,
    SUM(CASE WHEN f.isWantedCriminal THEN 1 ELSE 0 END) AS criminals_detected
FROM olap.fact_border_crossings f
JOIN olap.dim_date d ON f.passport_date_key = d.date_key
GROUP BY d.year_num
ORDER BY d.year_num DESC;
```

Запрос 2: Ищем популярные типы вещей в сумках в разрезе стран граждан
```sql
SELECT 
    e.countryName,
    l.mainItemType,
    COUNT(f.id) AS total_crossings
FROM olap.fact_border_crossings f
JOIN olap.dim_entrant e ON f.entrant_id = e.passport_id
JOIN olap.dim_luggage_summary l ON f.luggage_id = l.luggage_id
WHERE l.mainItemType IS NOT NULL
GROUP BY e.countryName, l.mainItemType
ORDER BY total_crossings DESC;
```

Запрос 3: Проверяем процент преступников среди дипломатов и обычных граждан
```sql
SELECT 
    e.hasDiplomatStatus,
    COUNT(f.id) AS total_checked,
    SUM(CASE WHEN f.isWantedCriminal THEN 1 ELSE 0 END) AS wanted_count,
    ROUND(SUM(CASE WHEN f.isWantedCriminal THEN 1 ELSE 0 END) * 100.0 / COUNT(f.id), 2) AS criminal_percentage
FROM olap.fact_border_crossings f
JOIN olap.dim_entrant e ON f.entrant_id = e.passport_id
GROUP BY e.hasDiplomatStatus;
```
