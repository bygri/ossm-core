--Django's migrate command must be run after importing this SQL to create its own tables.

--USER
CREATE TABLE users (
  password varchar(128) NOT NULL,
  last_login timestamp with time zone NULL,
  pk serial NOT NULL PRIMARY KEY,
  is_active boolean NOT NULL,
  email varchar(255) NOT NULL UNIQUE,
  nickname varchar(40) NOT NULL UNIQUE,
  timezone_name varchar(40) NOT NULL,
  language_code varchar(6) NOT NULL,
  token varchar(20) NOT NULL UNIQUE,
  face_recipe varchar(255) NOT NULL,
  access_level smallint NOT NULL CHECK (access_level >= 0)
);
CREATE INDEX users_email ON users (email varchar_pattern_ops);
CREATE INDEX users_nickname ON users (nickname varchar_pattern_ops);
CREATE INDEX users_token ON users (token varchar_pattern_ops);

--LOCATION
CREATE TABLE locations (
  pk serial NOT NULL PRIMARY KEY,
  parent_pk INT REFERENCES locations(pk),
  name varchar(40) NOT NULL
);

--CLUB
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
