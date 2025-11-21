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

9.1 Функция проверяет каждый паспорт и определяет, достаточно ли для общей картины валидных паспортов.
Если невалидных минимум 3, то недостаточно.

```sql
CREATE OR REPLACE FUNCTION check_enough_valid_passports()
RETURNS BOOLEAN 
LANGUAGE plpgsql
AS $$
DECLARE
    passports_count INT;
    i INT := 1;
    invalid INT := 0;
    current_date DATE := CURRENT_DATE;
    is_valid BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO passports_count FROM identity.passport;

    WHILE i <= passports_count AND invalid < 3 LOOP
        SELECT (validUntil > current_date) INTO is_valid
        FROM identity.passport LIMIT 1 OFFSET (i-1);
        
        IF NOT is_valid THEN
            invalid := invalid + 1;
            RAISE INFO 'Invalid passport found, now: %', invalid;
        ELSE
            RAISE INFO 'Normal passport, demdalsh';
        END IF;
        
        i := i + 1;
    END LOOP;
    
    RETURN invalid < 3;
END;
$$;

DO $$
BEGIN
    RAISE INFO 'Достаточно ли валидных паспортов: %', check_enough_valid_passports();
END $$;
```

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
