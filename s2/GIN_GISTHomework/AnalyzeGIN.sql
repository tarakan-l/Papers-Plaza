EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM identity.passport
WHERE search_vector @@ to_tsquery('english', 'record & 12345');

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM identity.passport
WHERE metadata @> '{"active": true}';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM People.Entrant
WHERE 'Country A' = ANY(travel_history);

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM People.Entrant 
WHERE travel_history && ARRAY['Country A', 'Country C'];

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM identity.passport
WHERE metadata ? 'id';