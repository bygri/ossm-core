# OSSM

An open-source, extensible strategic sports management game.

Come visit a running instance at http://ossm.world.

## Running your own instance in development or production

The project is currently divided into two components. There is a Swift backend
[ossm-core] which provides an API [ossm-api] consumed by a Django frontend
[ossm-web]. Data is stored in a Postgresql database.

### Postgres

Create a database and import the file ``create.sql`` in the root of the repo.
You will also want to populate the database with some fixtures, such as
Locations.

### ossm-core/ossm-api

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
``settings.py`` as a guide, run ``manage.py migrate`` to create Django's
tables, then you can run the web server.
    
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

* Django [ossm-web] is responsible for sessions and static file
  serving as well as rendering localised HTML.
  All requests for game data are passed through to the Swift core.
  Authentication here is handled by passing a token header to Swift.

* Swift [ossm-api in ossm-core] is in itself a mini-webserver which speaks only
  JSON. It receives requests from the front-end, authenticates them with the
  token header, fetches data from the datastore and returns it in JSON format so
  the front-end can display it. Other API consumers, should they be developed,
  may also access this service.
  
* Various workers [in ossm-core] are also scheduled regularly to perform tasks
  such as calculating match results. They will interact with the database.
