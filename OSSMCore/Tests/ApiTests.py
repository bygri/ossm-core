'''
Test the API views.
Because Swift PM cannot test executables, the binary needs to be tested instead.
Bonus: python-requests is very convenient for unit testing.

https://bugs.swift.org/browse/SR-1503
'''
import json
import os
import psycopg2
import requests
import subprocess
import sys
import time
import unittest


class TestApi(unittest.TestCase):

  def setUp(self):
    startApi()

  def tearDown(self):
    stopApi()

  def test_hello(self):
    r = requests.get(api_url).json()
    self.assertEqual(r['response'], 'Hello from ossm-api.')


class TestUserViews(unittest.TestCase):

  def setUp(self):
    startApi()

  def tearDown(self):
    stopApi()


### Configuration rubbish

config = None
db = None
api_url = None

_api_binary_path = None
_config_file_path = None
_create_queries = None

_api_process = None

def configure(args):
  global config
  global db
  global api_url
  global _api_binary_path
  global _config_file_path
  global _create_queries
  if len(args) != 3:
    print('Call with [path-to-api-binary] [path-to-config] [args-for-unittest]')
    exit(1)
  # Load configurations
  _api_binary_path = args[1]
  _config_file_path = args[2]
  with open(_config_file_path) as fp:
    config = json.load(fp)
  # Connect to database
  db = psycopg2.connect('dbname={} user={} host={} password={}'.format(
    config['database']['dbName'], config['database']['username'], config['database']['host'], config['database']['password']
  ))
  db.set_isolation_level(0)
  # Fetch create queries
  create_file_path = config['database']['createFilePath']
  with open(os.path.expanduser(create_file_path)) as fp:
    _create_queries = fp.read().split(';')
  # Build API url
  api_url = 'http://{}:{}/'.format(
    config['server']['host'], +config['server']['port']
  )


def startApi():
  global _api_process
  # Re-create database tables
  cur = db.cursor()
  for query in _create_queries:
    if query.strip(' \n\t') != '':
      cur.execute(query)
  # Create a root location without which the API will not start
  cur.execute('INSERT INTO locations (parent_pk, name) VALUES (NULL, \'World\')')
  # Begin API binary
  _api_process = subprocess.Popen([_api_binary_path, _config_file_path])
  time.sleep(0.5)


def stopApi():
  _api_process.terminate()


if __name__ == '__main__':
  # Configure wants the first three arguments
  configure(sys.argv[:3])
  # Unittest wants the remaining arguments
  sys.argv = [sys.argv[0], '-v'] + sys.argv[3:]
  unittest.main()
