-- 1. Очистка со сбросом счетчиков ID (RESTART IDENTITY)
TRUNCATE TABLE
    identity.passport, 
    identity.country, 
    Items.LuggageItem, 
    Items.Luggage, 
    Items.LuggageItemType, 
    Criminal.Case, 
    Criminal.CaseType, 
    People.Entrant 
RESTART IDENTITY CASCADE;

-- 2. Справочники
INSERT INTO identity.country (name, code)
SELECT 'Country ' || i, i::text
FROM generate_series(1, 100) AS s(i);

INSERT INTO Items.LuggageItemType (itemName)
VALUES ('Bag'), ('Suitcase'), ('Backpack'), ('Box'), ('Other');

INSERT INTO Criminal.CaseType (description)
VALUES ('Minor'), ('Major'), ('Critical');

-- 3. ТАБЛИЦА 1: identity.passport (250к)
INSERT INTO identity.biometry (id)
SELECT i FROM generate_series(1, 250000) AS s(i);

INSERT INTO identity.passport (fullName, issueDate, validUntil, country, metadata, search_vector)
SELECT
    'Name ' || i,
    '2020-01-01'::date + (i % 365),
    '2030-01-01'::date + (i % 365),
    (floor(random() * 99) + 1)::int, 
    jsonb_build_object('id', i, 'active', true),
    to_tsvector('english', 'person record ' || i)
FROM generate_series(1, 250000) AS s(i);

UPDATE identity.passport SET biometry = id;

UPDATE identity.passport
SET biometry = NULL
WHERE id % 7 = 0;

-- 4. ТАБЛИЦА 2: Items.Luggage + Items.LuggageItem (250к)
INSERT INTO Items.Luggage (id)
SELECT i FROM generate_series(1, 250000) AS s(i);

INSERT INTO Items.LuggageItem (itemType_Id, luggage_id, weight)
SELECT
    (floor(random() * 5) + 1)::int,
    i,
    (random() * 20)::decimal(9,4)
FROM generate_series(1, 250000) AS s(i);

-- 5. ТАБЛИЦА 3: Criminal.Case (250к)
INSERT INTO Criminal.Case (caseType_id, case_details)
SELECT
    CASE WHEN random() < 0.8 THEN 1 ELSE (floor(random() * 2) + 2)::int END,
    jsonb_build_object('priority', random())
FROM generate_series(1, 250000) AS s(i);

-- 6. ТАБЛИЦА 4: People.Entrant (250к)
INSERT INTO People.Entrant (passportId, travel_history, last_seen)
SELECT
    i,
    ARRAY['Country A', 'Country B'],
    tsrange((now() - interval '1 day' * (random() * 100))::timestamp, now()::timestamp)
FROM generate_series(1, 250000) AS s(i);

-- 7. NULL-значения
UPDATE identity.passport SET biometry = NULL WHERE id % 7 = 0;
