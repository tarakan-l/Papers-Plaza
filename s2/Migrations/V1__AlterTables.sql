ALTER TABLE identity.passport ADD COLUMN metadata JSONB DEFAULT '{}', ADD COLUMN tags TEXT[] DEFAULT '{}', ADD COLUMN validity_period TSRANGE;
ALTER TABLE identity.biometry ADD COLUMN fingerprints JSONB, ADD COLUMN photo_coords BOX;
ALTER TABLE papers.workPermission ADD COLUMN restrictions JSONB, ADD COLUMN allowed_regions TEXT[];
ALTER TABLE papers.entryPermission ADD COLUMN visit_window TSRANGE;
ALTER TABLE Criminal.Case ADD COLUMN evidence_locations POINT[], ADD COLUMN case_details JSONB;
ALTER TABLE People.Entrant ADD COLUMN risk_profile JSONB, ADD COLUMN travel_history TEXT[], ADD COLUMN last_seen TSRange;
ALTER TABLE Items.LuggageItem ADD COLUMN IF NOT EXISTS weight DECIMAL(9, 4) DEFAULT 0.0;

ALTER TABLE identity.country ADD COLUMN code CHAR(3), ADD COLUMN population INT, ADD COLUMN risk_level INT DEFAULT 1;
ALTER TABLE papers.vaccine ADD COLUMN manufacturer VARCHAR(100), ADD COLUMN doses_required INT DEFAULT 1;
ALTER TABLE Items.LuggageItemType ADD COLUMN weight_limit DECIMAL(9,4), ADD COLUMN is_prohibited BOOLEAN DEFAULT false;

ALTER TABLE identity.passport ADD COLUMN search_vector TSVECTOR, ALTER COLUMN biometry DROP NOT NULL;
ALTER TABLE papers.audit_log ADD COLUMN search_vector TSVECTOR, ALTER COLUMN description DROP NOT NULL;
