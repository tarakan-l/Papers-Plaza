-- Обновляем права на новые колонки
GRANT USAGE ON SCHEMA identity, papers, items, criminal, people TO app_user, readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA identity, papers, items, criminal, people TO readonly_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA identity, papers, items, criminal, people TO app_user;

-- Проверка: если данных меньше 1 млн суммарно, выбросить ошибку (опционально для контроля)
DO $$
BEGIN
   IF (SELECT count(*) FROM identity.passport) < 250000 THEN
      RAISE EXCEPTION 'Data generation failed: insufficient rows';
END IF;
END $$;
