from django.db import connection
from django.test import Client, TestCase
from ossm_auth.models import User


def setUpUserTable():
  connection.cursor().execute('''
    CREATE TABLE user (
      pk INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      email VARCHAR(255) NOT NULL,
      password VARCHAR(128) NOT NULL,
      token VARCHAR(40) UNIQUE,
      timezone_name VARCHAR(40) NOT NULL,
      language_code VARCHAR(6) NOT NULL,
      is_active BOOL NOT NULL,
      last_login DATETIME NULL,
      nickname VARCHAR(40) NOT NULL,
      face_recipe VARCHAR(255) NOT NULL,
      access_level SMALLINT UNSIGNED NOT NULL
    );
  ''')
  connection.cursor().execute('CREATE UNIQUE INDEX user_email ON user(email);')


class IndexPageTestCase(TestCase):
  def setUp(self):
    setUpUserTable()
  
  def test_index_page(self):
    c = Client()
    self.assertEqual(c.get('/').status_code, 200)


class SlackInviterPageTestCase(TestCase):
  def setUp(self):
    setUpUserTable()
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au', password='testpassword')
    self.user = User.objects.get()
  
  def test_get_inviter_page(self):
    c = Client()
    c.force_login(self.user)
    self.assertEqual(c.get('/slack/invite/').status_code, 200)
