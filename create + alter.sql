CREATE SCHEMA identity;

CREATE TABLE identity.country (
  id SERIAL PRIMARY KEY
  -- name VARCHAR(20) NOT NULL
);

CREATE TABLE identity.citizenEntryPermission (
  fromId INT REFERENCES identity.country(id),
  toId INT REFERENCES identity.country(id),
  CHECK (fromId <> toId)
);

CREATE TABLE identity.biometry (
  id SERIAL PRIMARY KEY
);

CREATE TABLE identity.passport (
  id SERIAL PRIMARY KEY,
  fullName VARCHAR(100) NOT NULL,
  issueDate DATE NOT NULL,
  validUntil DATE NOT NULL,
  biometry INT REFERENCES identity.biometry(id),
  country INT REFERENCES identity.country(id),
  CHECK (issueDate < validUntil)
);

CREATE SCHEMA papers;

CREATE SEQUENCE papers.documentIdSeq; 

CREATE TABLE papers.document (
    id INT PRIMARY KEY DEFAULT nextval('papers.documentIdSeq'),
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
  CHECK (issueDate < validUntil)
);

CREATE TABLE papers.vaccine (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE papers.workPermission (
    -- fullName VARCHAR(100) NOT NULL,
  countryOfIssue INT NOT NULL REFERENCES identity.country(id),
    activityType VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
) INHERITS (papers.document);

CREATE TABLE papers.entryPermission (
    countryOfIssue INT NOT NULL REFERENCES identity.country(id),
    fullName VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
) INHERITS (papers.document);

CREATE TABLE papers.vaccinationCertificate (
    issueByWhom VARCHAR(100) NOT NULL,
  -- vaccineId INT REFERENCES papers.vaccine(id),
  PRIMARY KEY (id)
) INHERITS (papers.document);

CREATE TABLE papers.diplomatCertificate (
    fullName VARCHAR(100) NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country(id),
  PRIMARY KEY (id)
) INHERITS (papers.document);

CREATE TABLE papers.diseaseVaccine 
(
  vaccineId INT REFERENCES papers.vaccine(id),
  vaccinationCertificateId INT REFERENCES papers.vaccinationCertificate(id),
  PRIMARY KEY (vaccineId, vaccinationCertificateId)
);

CREATE SCHEMA Items;

CREATE TABLE Items.Luggage(
    id SERIAL PRIMARY KEY
);

CREATE TABLE Items.LuggageItem (
    id SERIAL PRIMARY KEY,
    -- itemName TEXT NOT NULL,
    luggage_id INTEGER NOT NULL REFERENCES Items.Luggage(id) ON DELETE CASCADE 
);

CREATE SCHEMA Criminal;

CREATE TABLE Criminal.Record(
    id SERIAL PRIMARY KEY ,
    description TEXT NOT NULL
);

CREATE TABLE Criminal.Case(
    crimeId INT NOT NULL REFERENCES Criminal.Record(id) ON DELETE CASCADE,
    passportId INT NOT NULL REFERENCES identity.passport(id) ON DELETE CASCADE 
);

ALTER TABLE identity.country ADD COLUMN name VARCHAR(20) NOT NULL;
ALTER TABLE Items.LuggageItem ADD COLUMN itemName TEXT NOT NULL;
ALTER TABLE papers.workPermission ADD COLUMN fullName VARCHAR(100) NOT NULL;

ALTER TABLE Items.LuggageItem ADD COLUMN weight DECIMAL(9, 4) DEFAULT 0.0;
ALTER TABLE Items.LuggageItem DROP COLUMN weight;
ALTER TABLE Items.LuggageItem ALTER COLUMN itemName TYPE VARCHAR(255);
ALTER TABLE Items.LuggageItem ADD CONSTRAINT length_check CHECK (length(itemname) > 0);
