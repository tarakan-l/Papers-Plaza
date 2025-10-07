CREATE SCHEMA identity;

CREATE TABLE identity.country (
  id SERIAL PRIMARY KEY
  -- name VARCHAR(20) NOT NULL
);

CREATE TABLE identity.citizenEntryPermission (
  fromId INT REFERENCES identity.country(id),
  toId INT REFERENCES identity.country(id),
  CHECK (fromId <> toId),
  PRIMARY KEY (fromId, toId)
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

CREATE TABLE papers.vaccine (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE papers.workPermission (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    fullName VARCHAR(100) NOT NULL,
  countryOfIssue INT NOT NULL REFERENCES identity.country(id),
    activityType VARCHAR(100) NOT NULL,
  CHECK (issueDate < validUntil)
);

CREATE TABLE papers.entryPermission (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country(id),
    fullName VARCHAR(100) NOT NULL,
  CHECK (issueDate < validUntil)
);

CREATE TABLE papers.vaccinationCertificate (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    issueByWhom VARCHAR(100) NOT NULL,
  CHECK (issueDate < validUntil)
);

CREATE TABLE papers.diplomatCertificate (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    fullName VARCHAR(100) NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country(id),
  CHECK (issueDate < validUntil)
);

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
    luggage_id INTEGER NOT NULL REFERENCES Items.Luggage(id)
);

CREATE SCHEMA Criminal;

CREATE TABLE Criminal.Record(
    id SERIAL PRIMARY KEY ,
    description TEXT NOT NULL
);

CREATE TABLE Criminal.Case(
    crimeId INT NOT NULL REFERENCES Criminal.Record(id),
    passportId INT NOT NULL REFERENCES identity.passport(id),
    PRIMARY KEY (crimeId, passportId)
);

ALTER TABLE identity.country ADD COLUMN name VARCHAR(20) NOT NULL;
ALTER TABLE Items.LuggageItem ADD COLUMN weight DECIMAL(9, 4) DEFAULT 0.0;
ALTER TABLE Items.LuggageItem DROP COLUMN weight;
ALTER TABLE Items.LuggageItem ALTER COLUMN itemName TYPE VARCHAR(255);
ALTER TABLE Items.LuggageItem ADD CONSTRAINT length_check CHECK (length(itemname) > 0);
