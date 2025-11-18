## Базовые транзакции

1. COMMIT

1.1. Добавление нового пользователя, а потом присвоение ему новой биометрии
```sql
BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
     'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1
)

WITH new_biometry AS (
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id
)
UPDATE identity.passport
SET 
    biometry = new_biometry.id
FROM new_biometry
WHERE fullName = 'Евгений Жидко';

COMMIT;
```

2. ROLLBACK

2.1. Добавление нового пользователя, а потом присвоение ему новой биометрии (ROLLBACK-версия)
```sql
BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
    'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1
)

WITH new_biometry AS (
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id
)
UPDATE identity.passport
SET 
    biometry = new_biometry.id
FROM new_biometry
WHERE fullName = 'Евгений Жидко';

ROLLBACK;
```
Изначально
![фото](transactions_screenshots/2_1_start.png)

До rollback
![фото](transactions_screenshots/2_1_do.png)

После rollback
![фото](transactions_screenshots/2_1_posle.png)

3. ERROR

3.1. Добавление нового пользователя с невозможным id
```sql

BEGIN;

INSERT INTO identity.passport (
    fullName,
    issueDate,
    validUntil,
    biometry,
    country
) VALUES (
    'Евгений Жидко',
    '2023-01-15',
    '2033-01-15',
    1,
    1 / 0
)

ROLLBACK;
```