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

INSERT INTO papers.vaccine (name) VALUES 
('БЦЖ'), 
('вакцина Солка'), 
('вакцина против гепатита В'), 
('вакцина против тифа'), 
('пневмококовая вакцина');

INSERT INTO papers.workPermission 
(issueDate, validUntil, fullName, countryOfIssue, activityType) VALUES 
('2025-01-01', '2026-01-01', 'Ivan Ivanov', 3, 'IT Specialist'), 
('2024-05-15', '2025-05-15', 'John Smith', 1, 'Engineer'), 
('2025-03-10', '2026-03-10', 'Pierre Dubois', 2, 'Doctor'); 

INSERT INTO papers.entryPermission 
(issueDate, validUntil, countryOfIssue, fullName) VALUES 
('2025-02-01', '2025-08-01', 1, 'Maria Schmidt'), 
('2024-11-20', '2025-05-20', 3, 'Akira Tanaka'), 
('2025-04-01', '2025-10-01', 4, 'Michael Johnson'); 

INSERT INTO papers.vaccinationCertificate 
(issueDate, validUntil, issueByWhom) VALUES 
('2024-01-01', '2030-01-01', 'WHO Clinic Berlin'), 
('2025-05-10', '2031-05-10', 'Ministry of Health France'), 
('2023-12-15', '2029-12-15', 'Moscow Health Department'); 

INSERT INTO papers.diplomatCertificate (issueDate, validUntil, fullName, countryOfIssue) VALUES 
('2025-01-01', '2027-01-01', 'Sergey Petrov', 3), 
('2024-06-01', '2026-06-01', 'Alice Brown', 4), 
('2025-02-20', '2028-02-20', 'Hiroshi Yamamoto', 1); 

INSERT INTO papers.diseaseVaccine (vaccineId, vaccinationCertificateId) VALUES 
(1, 1), -- БЦЖ в сертификате 1 
(2, 2), -- вакцина Солка в сертификате 2 
(3, 3), -- вакцина против гепатита В в сертификате 3 
(1, 2), -- БЦЖ тоже в сертификате 2 
(4, 3); -- вакцина против тифа в сертификате 3


INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;
INSERT INTO identity.biometry DEFAULT VALUES;

INSERT INTO Criminal.Case(description) VALUES
('Украл сладкий рулет'),
('Убил человека'),
('Побег из тюрьмы'),
('Сделал пост в сети');

INSERT INTO Items.Luggage DEFAULT VALUES;
INSERT INTO Items.Luggage DEFAULT VALUES;
INSERT INTO Items.Luggage DEFAULT VALUES;
INSERT INTO Items.Luggage DEFAULT VALUES;

INSERT INTO Items.LuggageItem(itemName, luggage_id) VALUES 
('Пистолет', 1),
('Абобус', 1),
('Laptop', 2);


INSERT INTO Criminal.Record(crimeId, biometryId) VALUES 
(1, 1),
(1, 2),
(3, 2),
(4, 3);


UPDATE Items.LuggageItem
SET itemName = 'Пистолет ПМ'
WHERE id = 1;

UPDATE Criminal.Case
SET description = 'Кража драгоценностей из музея'
WHERE id = 1;

UPDATE Items.LuggageItem
SET itemName = 'Лабубу'
WHERE id = 2;
