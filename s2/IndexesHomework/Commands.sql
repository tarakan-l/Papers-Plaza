EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM identity.passport WHERE fullName = 'Name 12345';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM Items.LuggageItem WHERE weight > 19.5;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM Criminal.Case WHERE caseType_id IN (2, 3);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM identity.passport WHERE fullName LIKE 'Name 100%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM identity.passport WHERE fullName LIKE '%999';
