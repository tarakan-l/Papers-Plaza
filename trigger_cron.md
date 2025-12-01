### Триггеры

1. NEW 

1.1 Выкидывать уведомление, если придёт чел из КНДР

```sql
CREATE OR REPLACE FUNCTION identity.notify_if_from_kndr()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.country = 3 THEN
        RAISE INFO 'очуметь, чел из КНДР';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_passport
    BEFORE INSERT OR UPDATE ON identity.passport
    FOR EACH ROW
    EXECUTE FUNCTION identity.notify_if_from_kndr();
```

![фото](trigger_cron_screenshots/1.1_regular_insert.png)
![фото](trigger_cron_screenshots/1.1_regular_result.png)
![фото](trigger_cron_screenshots/1.1_special_insert.png)
![фото](trigger_cron_screenshots/1.1_special_result.png)

2. OLD

2.1 Предотвратить изменение страны в паспорте

```sql
CREATE OR REPLACE FUNCTION identity.prevent_country_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.country <> NEW.country THEN
        RAISE EXCEPTION 'Изменение страны в паспорте запрещено! Заводи новый паспорт, придурок! Паспорт ID %', OLD.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_country_change
    BEFORE UPDATE OF country ON identity.passport
    FOR EACH ROW
    EXECUTE FUNCTION identity.prevent_country_change();
```

3. BEFORE

4. AFTER

5. Row level

6. Statement level

7. Отображение списка триггеров

### Кроны

8. Кроны

9. Запрос на просмотр выполнения кронов

10. Запрос на просмотр кронов
