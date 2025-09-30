INSERT INTO identity.country (name) VALUES
('Россия'),
('США'),
('КНДР'),
('Китай');

INSERT INTO identity.citizenEntryPermission (fromId, toId) VALUES
(1, 4),
(2, 1),
(2, 4),
(3, 1),
(4, 1),
(4, 2);

INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;

INSERT INTO Criminal.Record(description) VALUES
('Украл сладкий рулет');

INSERT INTO Items.Luggage DEFAULT VALUES;

INSERT INTO Items.LuggageItem(itemName, luggage_id) VALUES 
('Пистолет', 1);

INSERT INTO Criminal.Case(crimeId, passportId) VALUES 
(1, 1);


UPDATE Items.LuggageItem
SET itemName = 'Пистолет ПМ'
WHERE id = 1;

UPDATE Criminal.Record
SET description = 'Кража драгоценностей из музея'
WHERE id = 1;

UPDATE Items.LuggageItem
SET itemName = 'Лабубу'
WHERE id = 2;
