## Процедуры

1. Процедуры

1.1 Создать всех пользователей вместе с необходимыми документами

```sql
CREATE OR REPLACE PROCEDURE create_default_user(fullName VARCHAR(100), country INT)
LANGUAGE plpgsql
AS $$
DECLARE
    new_biometry_id INT;
BEGIN
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id INTO new_biometry_id;

    INSERT INTO identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    ) VALUES (
        fullName,
        '2023-01-15',
        '2033-01-15',
        new_biometry_id,
        country);
    END;
$$;

CALL create_default_user('Евгений Газово', 1);
```

2. Запрос просмотра всех процедур

```sql
SELECT *
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE';
```

## Функции

3. Функции (без переменных)

3.1 Возвращает true, если входная строка состоит из  2 слов

```sql
CREATE OR REPLACE FUNCTION has_2_words(str VARCHAR(100))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN str like '_% _%';
END;
$$;

select itemName
from items.luggageitemtype
where has_2_words(itemname);
```

4. Функции (с переменными)

4.1 Получить самый новый паспорт

```sql
CREATE OR REPLACE FUNCTION get_last_passport()
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    max_date DATE;
    result RECORD;
BEGIN
    SELECT MAX(issueDate)
    FROM identity.passport
    INTO max_date;

    SELECT * FROM identity.passport
    WHERE issueDate = max_date
    INTO result;

    RETURN result;
END;
$$;

select get_last_passport()
```

5. Запрос просмотра всех функций

```sql
SELECT *
FROM information_schema.routines
WHERE routine_type = 'FUNCTION';
```

## DO

6. Do

## Прочее

7. IF

8. CASE

9. WHILE

10. EXCEPTION

10.1 Попытаться посчитать 1 / 0

```sql
DO $$
BEGIN
    RAISE INFO '1/0 = %', (1 / 0);
EXCEPTION
    WHEN division_by_zero THEN
        RAISE INFO 'Ага, щас, размечтался';
END $$;
```

11. RAISE

11.1 Вывести количество паспортов

```sql
DO $$
BEGIN
    RAISE INFO 'Кол-во %', (SELECT COUNT(*) FROM identity.passport);
END $$;
```
