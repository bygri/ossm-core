# OSSM

An open-source, extensible strategic sports management game.

Come visit a running instance at http://ossm.world.

## Running your own instance in development or production

The project is currently divided into two components. There is a Swift backend
[ossm-core] which provides an API consumed by a Django frontend [ossm-web]. Data
must be stored in a Postgresql database.

### Postgres

Create a database and import the following SQL:

    CREATE TABLE "users" (
      "password" varchar(128) NOT NULL,
      "last_login" timestamp with time zone NULL,
      "pk" serial NOT NULL PRIMARY KEY,
      "is_active" boolean NOT NULL,
      "email" varchar(255) NOT NULL UNIQUE,
      "nickname" varchar(40) NOT NULL UNIQUE,
      "timezone_name" varchar(40) NOT NULL,
      "language_code" varchar(6) NOT NULL,
      "token" varchar(20) NOT NULL UNIQUE,
      "face_recipe" varchar(255) NOT NULL,
      "access_level" smallint NOT NULL CHECK ("access_level" >= 0)
    );
    CREATE INDEX "users_email" ON "users" ("email" varchar_pattern_ops);
    CREATE INDEX "users_nickname" ON "users" ("nickname" varchar_pattern_ops);
    CREATE INDEX "users_token" ON "users" ("token" varchar_pattern_ops);

### ossm-core

Build the project using the version of Swift found in the ``.swift_version``
file. The product is invoked using ``ossm-api [path-to-config-file]`` where the
config file should be in JSON format resembling this:

    {
      "loglevel": 1, // 1: Error, 2: Warn, 3: Debug
      "server": {
        "host": "0.0.0.0",
        "port": 8001
      },
      "database": {
        "host": "127.0.0.1",
        "port": 5432,
        "username": "ossm",
        "password": "password",
        "dbName": "ossm"
      }
    }

### ossm-web

Create the file ``ossm-web/ossm/local_settings.py`` using the header of
``settings.py`` as a guide, then run the project.
    
## Contributing

You are encouraged to sign up at http://ossm.world and request an invite to our
Slack group. Most of the work to be done requires no coding at all so feel free
to help out no matter what your skills.

## General architecture

A goal of this project is 'as much Swift as possible'. At this moment I judge
the completeness of Swift web frameworks to be a little lacking, especially in
the areas of templating and session handling, therefore the web interface is
powered by Django. This also gives the benefit of forcing us to use our own
API.

* The user speaks to Django (through nginx and uwsgi)

* Django [ossm-web] is responsible for sessions, authentication and static file
  serving as well as rendering localised HTML.
  All requests for game data are passed through to the Swift core.
  Authentication here is handled by passing a token header to Swift. This part
  touches only the User table in the database, along with the various Django
  tables for sessions and admin.

* Swift [ossm-api in ossm-core] is in itself a mini-webserver which speaks only
  JSON. It receives requests from the front-end, authenticates them with the
  token header, fetches data from the datastore and returns it in JSON format so
  the front-end can display it. Other API consumers, should they be developed,
  may also access this service.
  
* Various workers [in ossm-core] are also scheduled regularly to perform tasks
  such as calculating match results. They will interact with the database.
