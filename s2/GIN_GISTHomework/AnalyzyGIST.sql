EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM People.Entrant
WHERE last_seen @> '2026-03-10 12:00:00'::timestamp;

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM identity.passport 
WHERE validity_period && tsrange('2025-01-01'::timestamp, '2027-01-01'::timestamp);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *, evidence_locations <-> point(0,0) as distance
FROM Criminal.Case
WHERE (evidence_locations <-> point(0,0)) < 10
ORDER BY evidence_locations <-> point(0,0)
    LIMIT 10;


EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM People.Entrant 
WHERE last_seen << tsrange('2026-01-01'::timestamp, '2026-02-01'::timestamp);

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM People.Entrant 
WHERE last_seen = tsrange('2025-01-01'::timestamp, '2026-01-01'::timestamp);