import app
from flask_mysqldb import MySQL

MySQL = MySQL()

class Mysql():
	def __init__(self, MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD, MYSQL_PORT, MYSQL_CURSORCLASS):
		self.MySQL['MYSQL_HOST'] = MYSQL_HOST
		self.MySQL['MYSQL_USER'] = MYSQL_USER
		self.MySQL['MYSQL_DB'] = MYSQL_DB
		self.MySQL['MYSQL_PASSWORD'] = MYSQL_PASSWORD
		self.MySQL['MYSQL_PORT'] = MYSQL_PORT
		self.MySQL['MYSQL_CURSORCLASS'] = MYSQL_CURSORCLASS

class User(Mysql):

	def getSections(self):
		pass

class Admin(User):
	pass