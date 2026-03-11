------GIN INDEXES DATA------
  
<img width="1450" height="1876" alt="thidHomeworkReport" src="https://github.com/user-attachments/assets/796b0916-106a-4d7c-b34a-0e1126bde686" />


------GIST INDEXES DATA------

(in the last case from Exec time of 25 ms to 0.034 ms, nice crop by me, sorry)

<img width="2744" height="2166" alt="thirdHomeworkAdding" src="https://github.com/user-attachments/assets/98da6d5d-e9d7-482a-a114-97f4ae211fea" />

------JOINS------

Hash join:
```sql
SELECT p.fullName, c.name
FROM identity.passport p
JOIN identity.country c ON p.country = c.id;
```

<img width="751" height="579" alt="image" src="https://github.com/user-attachments/assets/80b852fd-89b2-4ab1-a2fa-342adf6cedb0" />

Nested loop:
```sql
SELECT p.fullName, b.id
FROM identity.passport p
JOIN identity.biometry b ON p.biometry = b.id
WHERE p.id > 500 and p.id < 10000; 
```

<img width="819" height="727" alt="image" src="https://github.com/user-attachments/assets/cd8a8c4b-347d-4aad-97b2-298be8008d20" />

Merge:
```sql
SELECT p.id, e.passportId 
FROM identity.passport p 
JOIN People.Entrant e ON p.id = e.passportId 
ORDER BY p.id;
```

<img width="882" height="553" alt="image" src="https://github.com/user-attachments/assets/3d262caa-198d-4ca7-8312-2974f55331e1" />

Chain of joins:
```sql
SELECT p.fullName, v.name as vaccine_name
FROM People.Entrant e
JOIN identity.passport p ON e.passportId = p.id
JOIN papers.vaccinationCertificate vc ON e.vaccinationCertificateId = vc.id
JOIN papers.diseaseVaccine dv ON vc.id = dv.vaccinationCertificateId
JOIN papers.vaccine v ON dv.vaccineId = v.id
LIMIT 100;
```

<img width="990" height="691" alt="image" src="https://github.com/user-attachments/assets/35b32197-4f80-419a-a093-ea8258dcdd24" />
<img width="1024" height="115" alt="image" src="https://github.com/user-attachments/assets/1f65a313-6e40-466d-a2a4-13aa4a285d29" />

Left join with null fields:
```sql
SELECT p.fullName, b.id
FROM identity.passport p
LEFT JOIN identity.biometry b ON p.biometry = b.id
WHERE b.id IS NULL
LIMIT 100;
```

<img width="811" height="747" alt="image" src="https://github.com/user-attachments/assets/429c250c-edfb-4502-9435-084dbe1eeb39" />
