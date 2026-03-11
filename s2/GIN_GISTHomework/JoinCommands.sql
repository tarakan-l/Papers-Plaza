--HASH
SELECT p.fullName, c.name
FROM identity.passport p
JOIN identity.country c ON p.country = c.id;


--NESTED
SELECT p.fullName, b.id
FROM identity.passport p
JOIN identity.biometry b ON p.biometry = b.id
WHERE p.id > 500 and p.id < 10000; 

--MERGE
SELECT p.id, e.passportId
FROM identity.passport p
JOIN People.Entrant e ON p.id = e.passportId
ORDER BY p.id;

--COUPLE OF JOINS
SELECT p.fullName, v.name as vaccine_name
FROM People.Entrant e
JOIN identity.passport p ON e.passportId = p.id
JOIN papers.vaccinationCertificate vc ON e.vaccinationCertificateId = vc.id
JOIN papers.diseaseVaccine dv ON vc.id = dv.vaccinationCertificateId
JOIN papers.vaccine v ON dv.vaccineId = v.id
LIMIT 100;

--NULL
SELECT p.fullName, b.id
FROM identity.passport p
LEFT JOIN identity.biometry b ON p.biometry = b.id
WHERE b.id IS NULL
LIMIT 100;
