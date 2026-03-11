CREATE INDEX idx_gin_fts ON identity.passport USING GIN (search_vector);
CREATE INDEX idx_gin_meta ON identity.passport USING GIN (metadata);
CREATE INDEX idx_gin_tags ON People.Entrant USING GIN (travel_history);

ALTER TABLE Criminal.Case ALTER COLUMN evidence_locations TYPE POINT USING evidence_locations[1];
CREATE INDEX idx_gist_last_seen ON People.Entrant USING GIST (last_seen);
CREATE INDEX idx_gist_validity ON identity.passport USING GIST (validity_period);
CREATE INDEX idx_gist_locations ON Criminal.Case USING GIST (evidence_locations);
