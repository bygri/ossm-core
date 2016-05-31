'''
Test the API views.
Because Swift PM cannot test executables, the binary needs to be tested instead.
Bonus: python-requests is very convenient for unit testing.

https://bugs.swift.org/browse/SR-1503

Secret key MUST be 'abracadabra' for getTestUser() to have the correct password set.
'''
import json
import os
import psycopg2
import requests
import subprocess
import sys
import time
import unittest


class TestUserViews(unittest.TestCase):

  def setUp(self):
    startApi()

  def tearDown(self):
    stopApi()

  def getTestUser(self):
    cur = db.cursor()
    cur.execute('''
      INSERT INTO users
      (email, password, auth_token, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created)
      VALUES
      ('test@test.com', '06b8cc0b030d942ee8689e440413d2e63e141c220cfeea03c01c4c68f1b4d88e', 'ABCDEFabcdef12345678', TRUE, 1, 'testuser', 'Australia/Sydney', 'en-au', '', '2016-01-01 00:00:00+0000')
      RETURNING pk, auth_token
    ''')
    row = cur.fetchone()
    cur.close()
    self.userPk = row[0]
    self.userPassword = 'password'
    self.userEmail = 'test@test.com'
    self.authToken = row[1]


  def test_view_user_detail(self):
    self.getTestUser()
    # Unauthenticated should return 401
    r = requests.get(api_url+'/user/12345')
    self.assertEqual(r.status_code, 401)
    # Fetching a non-existing user should fail.
    r = requests.get(api_url+'/user/12345', headers={'Authorization': self.authToken})
    self.assertEqual(r.status_code, 404)
    # Fetching an existing user should succeed
    r = requests.get(api_url+'/user/{}'.format(self.userPk), headers={'Authorization': self.authToken})
    self.assertEqual(r.status_code, 200)


  def test_view_user_authenticate(self):
    self.getTestUser()
    r = requests.post(api_url+'/user/authenticate', data={'email': self.userEmail, 'password': self.userPassword})
    self.assertEqual(r.status_code, 200)
    self.assertEqual(r.json()['data']['authToken'], self.authToken)


  def test_view_user_create(self):
    email = 'test@user.com'
    password = 'password'
    r = requests.post(api_url+'/user/create', data={
      'email': email,
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'testuser'
    })
    self.assertEqual(r.status_code, 201)
    
  def test_view_user_create_invalid(self):
    # Invalid email
    r = requests.post(api_url+'/user/create', data={
      'email': 'notanemail',
      'password': 'password',
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'invalidemail'
    })
    print(r)
    self.assertEqual(r.status_code, 400)
    # Invalid language
    r = requests.post(api_url+'/user/create', data={
      'email': 'test2@user.com',
      'password': 'password',
      'timezoneName': 'Australia/Melbourne',
      'language': 'martian',
      'nickname': 'invalidlanguage'
    })
    self.assertEqual(r.status_code, 400)
    # Invalid nickname
    r = requests.post(api_url+'/user/create', data={
      'email': 'test3@user.com',
      'password': 'password',
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'Not%a$valid@nickname'
    })
    self.assertEqual(r.status_code, 400)


  def test_view_user_create_duplicate(self):
    email = 'test@user.com'
    password = 'password'
    r = requests.post(api_url+'/user/create', data={
      'email': email,
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'testuser'
    })
    self.assertEqual(r.status_code, 201)
    r = requests.post(api_url+'/user/create', data={
      'email': email,
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'duplicateemail'
    })
    self.assertEqual(r.status_code, 400)
    r = requests.post(api_url+'/user/create', data={
      'email': 'duplicate@nickname.com',
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'testuser'
    })
    self.assertEqual(r.status_code, 400)


  def test_view_user_regenerate_token(self):
    self.getTestUser()
    # Attempt token regeneration (need the password)
    r = requests.post(api_url+'/user/regenerateToken/{}'.format(self.userPk), data={'password': self.userPassword})
    self.assertEqual(r.status_code, 200)
    newToken = r.json()['data']['authToken']
    self.assertNotEqual(self.authToken, newToken)
    # Confirm the token has been changed
    r = requests.get(api_url+'/user/{}'.format(self.userPk), headers={'Authorization': newToken})
    self.assertEqual(r.json()['data']['authToken'], newToken)


  def test_view_user_verify(self):
    self.getTestUser()
    # Create a user
    email = 'test@user.com'
    password = 'password'
    r = requests.post(api_url+'/user/create', data={
      'email': email,
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'test2'
    })
    self.assertEqual(r.status_code, 201)
    pk = r.json()['data']['pk']
    verification_code = r.json()['data']['verificationCode']
    # Attempt verify with an incorrect code - should fail
    r = requests.post(api_url+'/user/verify/{}'.format(pk), data={'code': 'invalid_code'})
    self.assertEqual(r.status_code, 400)
    # Fetch user - should fail
    r = requests.get(api_url+'/user/{}'.format(pk), headers={'Authorization': self.authToken})
    self.assertEqual(r.status_code, 404)
    # Verify with a correct code
    r = requests.post(api_url+'/user/verify/{}'.format(pk), data={'code': verification_code})
    self.assertEqual(r.status_code, 204)
    # Fetch user - should succeed
    r = requests.get(api_url+'/user/{}'.format(pk), headers={'Authorization': self.authToken})
    self.assertEqual(r.status_code, 200)


  def test_signup_flow(self):
    # Create a user
    email = 'test@user.com'
    password = 'password'
    r = requests.post(api_url+'/user/create', data={
      'email': email,
      'password': password,
      'timezoneName': 'Australia/Melbourne',
      'language': 'en-au',
      'nickname': 'testuser'
    })
    self.assertEqual(r.status_code, 201)
    pk = r.json()['data']['pk']
    verification_code = r.json()['data']['verificationCode']
    # Attempt auth - should fail
    r = requests.post(api_url+'/user/authenticate', data={'email': email, 'password': password})
    self.assertEqual(r.status_code, 401)
    # Attempt auth with incorrect credentials - should fail
    r = requests.post(api_url+'/user/authenticate', data={'email': email, 'password': 'wrongpassword'})
    self.assertEqual(r.status_code, 401)
    # Attempt verify with an incorrect code - should fail
    r = requests.post(api_url+'/user/verify/{}'.format(pk), data={'code': 'invalid_code'})
    self.assertEqual(r.status_code, 400)
    # Attempt auth with incorrect credentials - should fail
    r = requests.post(api_url+'/user/authenticate', data={'email': email, 'password': 'wrongpassword'})
    self.assertEqual(r.status_code, 401)
    # Verify with a correct code
    r = requests.post(api_url+'/user/verify/{}'.format(pk), data={'code': verification_code})
    self.assertEqual(r.status_code, 204)
    # Attempt auth with incorrect credentials - should fail
    r = requests.post(api_url+'/user/authenticate', data={'email': email, 'password': 'wrongpassword'})
    self.assertEqual(r.status_code, 401)
    # Attempt auth with correct credentials
    r = requests.post(api_url+'/user/authenticate', data={'email': email, 'password': password})
    self.assertEqual(r.status_code, 200)
    authToken = r.json()['data']['authToken']


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
  api_url = 'http://{}:{}'.format(
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
