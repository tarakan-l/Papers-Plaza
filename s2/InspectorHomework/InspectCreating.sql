CREATE EXTENSION IF NOT EXISTS pageinspect;

CREATE TABLE test_mvcc (id int, val text);
INSERT INTO test_mvcc VALUES (1, 'original');

--INSPECTING
SET search_path TO test_lab, public;
SELECT lp, t_xmin, t_xmax, t_ctid, t_infomask::bit(16)
FROM heap_page_items(get_raw_page('test_mvcc', 0));