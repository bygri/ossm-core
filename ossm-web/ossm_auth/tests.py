from django.db import connection
from django.test import Client, TestCase
from .models import User


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


class RedirectLoggedInUserCase(TestCase):
  def setUp(self):
    setUpUserTable()
  
  def test_redirect_logged_in_user_view(self):
    c = Client()
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au', password='testpassword')
    self.assertTrue(c.login(username='email@email.com', password='testpassword'))
    response = c.get('/user/')
    self.assertEqual(response.url, '/user/1/')


class SignUpTestCase(TestCase):
  def setUp(self):
    setUpUserTable()
    
  def test_signup_page(self):
    # The signup page should GET properly
    c = Client()
    response = c.get('/user/signup/')
    # Don't redirect if not logged in
    self.assertFalse(hasattr(response, 'url'))

  def test_signup(self):
    # If one user signs up normally...
    form_details = {
      'email': 'email@email.com',
      'password': 'passywordy',
      'nickname': 'testuser',
      'timezone_name': 'Australia/Sydney',
      'language_code': 'en-au',
    }
    self.assertEqual(User.objects.count(), 0)
    c = Client()
    response = c.post('/user/signup/', form_details)
    # There should be one User created
    self.assertEqual(User.objects.count(), 1)
    user = User.objects.all()[0]
    # Their details should match what has been submitted
    self.assertEqual(user.email, form_details['email'])
    self.assertEqual(user.nickname, form_details['nickname'])
    self.assertEqual(user.timezone_name, form_details['timezone_name'])
    self.assertEqual(user.language_code, form_details['language_code'])
    # They should be able to log out and in again with the same credentials
    c.logout()
    self.assertTrue(c.login(username=form_details['email'], password=form_details['password']))
    # They should be unable to log in with incorrect password
    self.assertFalse(c.login(username=form_details['email'], password='OSTRICH'))

  def test_double_signup(self):
    # If two users sign up normally...
    self.assertEqual(User.objects.count(), 0)
    c = Client()
    c.post('/user/signup/', {
      'email': 'user1@user.com',
      'password': 'firstpassword',
      'nickname': 'user1',
      'timezone_name': 'Australia/Sydney',
      'language_code': 'en-au',
    })
    c.logout()
    self.assertEqual(User.objects.count(), 1)
    c.post('/user/signup/', {
      'email': 'user2@user.com',
      'password': 'secondpassword',
      'nickname': 'user2',
      'timezone_name': 'Pacific/Auckland',
      'language_code': 'pirate',
    })
    # Both should be able to sign up
    self.assertEqual(User.objects.count(), 2)
    user1 = User.objects.get(email='user1@user.com')
    user2 = User.objects.get(email='user2@user.com')

  def test_invalid_signup(self):
    # Cannot sign up with invalid email
    self.assertEqual(User.objects.count(), 0)
    c = Client()
    c.post('/user/signup/', {
      'email': 'INVALID',
      'password': 'password',
      'nickname': 'user',
      'timezone_name': 'Australia/Sydney',
      'language_code': 'en_au',
    })
    self.assertEqual(User.objects.count(), 0)
  
  def test_signup_already_logged_in(self):
    # Cannot sign up again if already logged in
    c = Client()
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au', password='testpassword')
    self.assertTrue(c.login(username='email@email.com', password='testpassword'))
    response = c.get('/user/signup/')
    # We should be redirected to the user's profile page
    self.assertEqual(response.url, '/user/1/')


class UserProfilePageTestCase(TestCase):
  def setUp(self):
    setUpUserTable()
    User.objects.create_user('user1@email.com', 'user1', 'Australia/Sydney', 'en-au', password='testpassword')
    User.objects.create_user('user2@email.com', 'user2', 'Australia/Sydney', 'en-au', password='testpassword')
    self.user1 = User.objects.get(nickname='user1')
    self.user2 = User.objects.get(nickname='user2')
  
  def test_visit_page_unauthenticated(self):
    # If we visit a user's profile page while not logged in, we only see basic info
    c = Client()
    response = c.get('/user/1/')
    self.assertFalse(response.context['is_my_profile'])
    # If we visit our own profile page while logged in, we see all info
    c.login(username='user1@email.com', password='testpassword')
    response = c.get('/user/1/')
    self.assertTrue(response.context['is_my_profile'])
    # If we visit another's profile page while logged in, back to basic info
    response = c.get('/user/2/')
    self.assertFalse(response.context['is_my_profile'])


class UserTestCase(TestCase):
  def setUp(self):
    setUpUserTable()

  def test_create_user(self):
    self.assertEqual(User.objects.count(), 0)
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au')
    self.assertEqual(User.objects.count(), 1)

  def test_create_superuser(self):
    self.assertEqual(User.objects.count(), 0)
    User.objects.create_superuser('email@email.com', 'nickname', 'Australia/Sydney', 'en-au', password='passwordy')
    self.assertEqual(User.objects.count(), 1)

  def test_short_and_full_names(self):
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au')
    user = User.objects.get()
    self.assertEqual(user.get_short_name(), 'nickname')
    self.assertEqual(user.get_full_name(), 'nickname')

  def test_admin_privileges(self):
    User.objects.create_user('email@email.com', 'nickname', 'Australia/Sydney', 'en-au')
    user = User.objects.get()
    # A basic user should have all perms but not admin console access
    self.assertEqual(user.access_level, User.AccessLevel.User.value)
    self.assertTrue(user.has_perm('test'))
    self.assertTrue(user.has_module_perms('test'))
    self.assertFalse(user.is_staff)
    # Moderator still has no admin access
    user.access_level = User.AccessLevel.Moderator.value
    self.assertFalse(user.is_staff)
    # Admin does have access
    user.access_level = User.AccessLevel.Administrator.value
    self.assertTrue(user.is_staff)
    # So does Superuser
    user.access_level = User.AccessLevel.Administrator.value
    self.assertTrue(user.is_staff)
