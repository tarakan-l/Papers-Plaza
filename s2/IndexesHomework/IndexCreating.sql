CREATE INDEX idx_passport_name_btree ON identity.passport USING btree (fullName);
CREATE INDEX idx_passport_date_btree ON identity.passport USING btree (issueDate);

DROP INDEX identity.idx_passport_name_btree;
CREATE INDEX idx_passport_name_hash ON identity.passport USING hash (fullName);
