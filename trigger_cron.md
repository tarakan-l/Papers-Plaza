I. Триггеры


1. NEW


2. OLD


3. BEFORE

3.1.  Триггер для валидации дат при добавлении сертефиката дипломата
```sql
CREATE OR REPLACE FUNCTION papers.check_insert_diplomatcertificate()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.validuntil < NOW() THEN
        RAISE EXCEPTION 'validUntil cannot be in the past';
    END IF;

    IF NEW.issuedate > NOW() THEN
        RAISE EXCEPTION 'issueDate cannot be in the future';
    END IF;

    RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER before_insert_diplomatcertificate
BEFORE INSERT ON papers.diplomatcertificate
FOR EACH ROW
EXECUTE FUNCTION papers.check_insert_diplomatcertificate();
```

```sql
INSERT INTO papers.diplomatCertificate (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue
    )
VALUES (
        '2026-01-01',
        '2030-01-01',
        'Wrong Person',
        2
    )
```
![screen](/trigger_cron_screenshots/trigger_3_1.png)


4. AFTER

4.1. Триггер для обновления соответствующих данных для въезда пользовалеля при обновлении разрешения на работу
```sql
CREATE OR REPLACE FUNCTION papers.update_documents()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE papers.entryPermission
    SET countryOfIssue = NEW.countryOfIssue,
        validUntil = NEW.validUntil,
        issueDate = NEW.issueDate
    WHERE fullName = NEW.fullName;

    RETURN NEW;
END;
$$ language plpgsql;


CREATE TRIGGER after_change_workPermission
AFTER INSERT OR UPDATE ON papers.workPermission
FOR EACH ROW
EXECUTE FUNCTION papers.update_documents();
```

```sql
INSERT INTO papers.workPermission (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue,
        activityid
    )
VALUES (
        '2025-03-01',
        '2030-09-01',
        'Sam Altman',
        1,
        2
    );
```

![schemas](/trigger_cron_screenshots/trigger_4_1.png)


5. Row level

5.1. Триггер для проеверки того, что у сертефикаата вакцины не будет одинаковых вакцин
```sql
CREATE OR REPLACE FUNCTION papers.prevent_overlapping_vaccines()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM papers.diseaseVaccine dv
        JOIN papers.vaccinationCertificate vc
            ON vc.id = dv.vaccinationCertificateId
        WHERE dv.vaccineId = NEW.vaccineId
          AND vc.validUntil >= CURRENT_DATE
    ) THEN
        RAISE EXCEPTION 'A valid vaccination certificate for this vaccine already exists.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_vaccine_overlap
BEFORE INSERT ON papers.diseaseVaccine
FOR EACH ROW
EXECUTE FUNCTION papers.prevent_overlapping_vaccines();
```

```sql
INSERT INTO papers.diseasevaccine (
        vaccineId,
        vaccinationCertificateId
    )
VALUES (1, 1);
```

![schemas](/trigger_cron_screenshots/trigger_5_1.png)


6. Statement level

6.1. Логгирование массовых изменений в workPermission
```sql
CREATE OR REPLACE FUNCTION papers.log_bulk_insert_work()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO papers.audit_log (description)
    VALUES ('Bulk INSERT into workPermission table');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_bulk_work_insert
AFTER INSERT ON papers.workPermission
FOR EACH STATEMENT
EXECUTE FUNCTION papers.log_bulk_insert_work();
```

```sql
INSERT INTO papers.workPermission (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue,
        activityid
    )
VALUES (
        '2025-03-01',
        '2030-09-01',
        'Sam Altman',
        1,
        2
    );
```

![schemas](/trigger_cron_screenshots/trigger_6_1.png)

---
II. Отображение списка триггеров

```sql
SELECT *
FROM information_schema.triggers;
```

![screen](./trigger_cron_screenshots/triggers_list.png)

---
III. Кроны

3.1. Ежедневная очистка таблиц с разрешениями на работу и въезд
```sql
SELECT cron.schedule(
    'Daily Cleanup of Expired Permissions',
    '0 0 * * *',
    $$
    DELETE FROM papers.workPermission WHERE validUntil < CURRENT_DATE;
      DELETE FROM papers.entryPermission WHERE validUntil < CURRENT_DATE;
    $$
);
```
![screen](./trigger_cron_screenshots/cron_1.png)