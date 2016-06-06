--Django's migrate command must be run after importing this SQL to create its own tables.

--USER
DO $$
  BEGIN
    BEGIN
      CREATE TABLE users (
        pk serial NOT NULL PRIMARY KEY,
        email varchar(255) NOT NULL UNIQUE,
        password varchar(128) NOT NULL,
        auth_token varchar(20) NOT NULL UNIQUE,
        verification_code varchar(20),
        is_active boolean NOT NULL,
        access_level smallint NOT NULL CHECK (access_level >= 0),
        nickname varchar(40) NOT NULL UNIQUE,
        timezone varchar(40) NOT NULL,
        language varchar(8) NOT NULL,
        face_recipe varchar(255) NOT NULL,
        date_created timestamp with time zone NOT NULL,
        last_login timestamp with time zone
      );
      CREATE INDEX users_email ON users (email varchar_pattern_ops);
      CREATE INDEX users_nickname ON users (nickname varchar_pattern_ops);
      CREATE INDEX users_auth_token ON users (auth_token varchar_pattern_ops);
    END;
  END;
$$;

--LOCATION
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
  pk serial NOT NULL PRIMARY KEY,
  parent_pk INT REFERENCES locations(pk),
  name varchar(40) NOT NULL
);

--CLUB
DROP TABLE IF EXISTS clubs CASCADE;
CREATE TABLE clubs (
  pk serial NOT NULL PRIMARY KEY,
  kind_code varchar(4) NOT NULL,
  owner_user_pk int NOT NULL REFERENCES users(pk),
  location_pk int NOT NULL REFERENCES locations(pk),
  name varchar(80) NOT NULL,
  badge_recipe varchar(255) NOT NULL,
  primary_colour varchar(6) NOT NULL,
  secondary_colour varchar(6) NOT NULL,
  tertiary_colour varchar(6) NOT NULL
);
