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
