CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin_123' SUPERUSER;
CREATE ROLE app_user WITH LOGIN PASSWORD 'app_123';
CREATE ROLE readonly_user WITH LOGIN PASSWORD 'read_123';

GRANT USAGE ON SCHEMA identity, papers, items, criminal, people TO app_user, readonly_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA identity, papers, items, criminal, people TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA identity, papers, items, criminal, people TO app_user;

GRANT SELECT ON ALL TABLES IN SCHEMA identity, papers, items, criminal, people TO readonly_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA identity, papers, items, criminal, people 
GRANT SELECT ON TABLES TO readonly_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA identity, papers, items, criminal, people 
GRANT ALL PRIVILEGES ON TABLES TO app_user;
