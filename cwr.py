from flask import Flask, render_template, Markup, request, redirect, url_for, session
from flask_mysqldb import MySQL
import json, sys


settings = {
	'application': {
		'name': 'Cisco IOS Commands v2',
		'admin_key': '',
		'default_columns': {
			'command': 'Команда',
			'mode': 'Режим',
			'description': 'Описание'
		},
	},
	'flask': {
		'host': '0.0.0.0',
		'secret_key': 'df606b8b5e94997883cb0f35b743d26bbf2153dc',
		'port': 9000,
		'debug': False,
		'dir' : {
			'template_folder': './templates/',
			'static_folder': './static/'
		},
	},
	'mysql': {
		'MYSQL_HOST': '127.0.0.1',
		'MYSQL_USER': 'pymysql',
		'MYSQL_DB': 'cisco',
		'MYSQL_PASSWORD': '',
		'MYSQL_PORT': 3306,
		'MYSQL_CURSORCLASS': 'DictCursor'
	}
}


def encode(string):
	return json.loads(string.replace("'", '"'))


app = Flask(__name__, **settings['flask']['dir'])

app.config['SECRET_KEY'] = settings['flask']['secret_key']

app.config.update(settings['mysql'])
mysql = MySQL(app)

app.add_template_global(encode, 'encode')
app.add_template_global(Markup, 'Markup')


@app.route("/favicon.ico", methods=['GET'])
def favicon():
	return "Злокачественная иконка"

@app.route("/", methods=['GET'])
def root():

	try:
		mysql.connection.ping()

		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT name, name_ru, href FROM section")
			sections = cursor.fetchall()

			return render_template('index.html', title=settings['application']['name'], section=sections)
	except:
		return render_template('errors/mysql.html', error=sys.exc_info())

@app.route("/<section>", methods=['GET'])
def sections(section):

	mysql.connection.ping()

	with mysql.connection.cursor() as cursor:
		cursor.execute("SELECT name, name_ru, href FROM section WHERE href=%s", ("/" + section,))
		pwd = cursor.fetchone()

	if pwd == None:
		return render_template('errors/not_found.html', page=section)
	else:
		mysql.connection.ping()

		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT id_table, table_name, default_columns, columns, comment FROM view_TableAndSection WHERE subsection IS NULL AND section=%s", (pwd['name'],))
			tables = cursor.fetchall()

			cursor.execute("SELECT * FROM view_TableAndCommands WHERE subsection IS NULL and section=%s ORDER BY id_command ASC", (pwd['name'],))
			commands = cursor.fetchall()

			cursor.execute("SELECT * FROM view_SecAndSub WHERE sec_name=%s", (pwd['name'],))
			subsections = cursor.fetchall()

		return render_template('section.html', title=pwd, data1=tables, default_columns=settings['application']['default_columns'], data2=commands, data3=subsections)

@app.route("/<section>/<subsection>", methods=['GET'])
def subsections(section, subsection):

	mysql.connection.ping()

	with mysql.connection.cursor() as cursor:

		cursor.execute("SELECT name, name_ru, href FROM section WHERE href=%s", ("/" + section,))
		pwd_sec = cursor.fetchone()

		cursor.execute("SELECT * FROM view_SecAndSub WHERE sub_href=%s", ("/" + subsection,))
		pwd_sub = cursor.fetchone()

	if pwd_sub == None:
		return render_template('not_found.html', page=subsection, section=section)
	else:
		mysql.connection.ping()

		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT id_table, table_name, default_columns, columns, comment FROM view_TableAndSection WHERE subsection IS NOT NULL AND subsection=%s", (pwd_sub['sub_name'],))
			tables = cursor.fetchall()

			cursor.execute("SELECT * FROM view_TableAndCommands WHERE subsection IS NOT NULL AND subsection=%s ORDER BY id_command ASC", (pwd_sub['sub_name'],))
			commands = cursor.fetchall()

		return render_template('subsection.html', title=pwd_sec, subtitle=pwd_sub, data1=tables, default_columns=settings['application']['default_columns'], data2=commands)

@app.route("/admin", methods=['POST', 'GET'])
def admin():
	admin_key = request.args.get('akey')

	if 'auth' not in session:
		session['auth'] = 0


	if admin_key == settings['application']['admin_key'] or session['auth'] == 1:
		if 'auth' in session:
			session['auth'] = 1

		if request.method == 'POST':
			if request.form['logout']:
				session.pop('auth', 0)
				return redirect(url_for('admin'))

		return render_template('admin/main.html')


	return render_template('admin/video.html')

@app.route("/admin/tableAdd", methods=['POST', 'GET'])
def tableAdd():

	if session['auth'] == 1:

		mysql.connection.ping()
		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT id_section, name FROM section")
			sections = cursor.fetchall()

			cursor.execute("SELECT id_subsection, name FROM subsection")
			subsections = cursor.fetchall()

		message = ''

		selected = {
			'id_section': None,
			'id_subsection': None
		}

		if request.method == 'POST':
			try:
				data = {
					'id_table': None,
					'id_section': int(request.form['section']),
					'id_subsection': None if int(request.form['subsection']) == 0 else int(request.form['subsection']),
					'table_name': request.form['tableName'],
					'default_columns': 1,
					'columns': None if not request.form['columns'] else str(request.form['columns']),
				}
			except werkzeug.exceptions.BadRequestKeyError:
				data = {
					'id_table': None,
					'id_section': int(request.form['section']),
					'id_subsection': None if int(request.form['subsection']) == 0 else int(request.form['subsection']),
					'table_name': request.form['tableName'],
					'default_columns': 0,
					'columns': None if not request.form['columns'] else str(request.form['columns']),

				}
			try:
				selected['id_section'] = data['id_section']
				selected['id_subsection'] = data['id_subsection']

				with mysql.connection.cursor() as cursor:
					cursor.execute("INSERT INTO tables (id_table, id_section, id_subsection, table_name, default_columns, columns) VALUES (%s, %s, %s, %s, %s, %s)",
						(data['id_table'], data['id_section'], data['id_subsection'], data['table_name'], data['default_columns'], data['columns'],)
					)
					mysql.connection.commit()
					message = 'Таблица "{0}" добавлена'.format(data['table_name'])
			except: #MySQLdb is not defined, поэтому ловим все исключения, и при помощи модуля sys получаем содержимое этого исключения. Вот так и живем ¯\_(ツ)_/¯
				message = 'Произошла ошибка: {0}'.format(sys.exc_info()[1])

		return render_template('admin/tableAdd.html', section=sections, subsection=subsections, message=message, data1=selected)

	else:
		return render_template('admin/video.html')

@app.route("/admin/commandAdd", methods=['POST', 'GET'])
def commandAdd():

	if session['auth'] == 1:

		message = ''

		try:
			if request.args.get('count') != None:
				count_elements = int(request.args.get('count'))
			else:
				count_elements = 1
				message = Markup('Используй GET-параметр <strong>count</strong><i>=кол-во</i> для создания нескольких записей' +
					'<br>Используй GET-параметр <strong>except</strong><i>=value</i>, чтобы исключить <i>table</i>, либо <i>mode</i> из цикла'
					+ '<br>'
				)
			if count_elements >= 100:
				message = Markup('Земля те пухом, бро <br>')

		except ValueError:
			return '<center>Укажите количество строк</center>'

		mysql.connection.ping()
		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT id_table, table_name, section, subsection FROM view_TableAndSection")
			tables = cursor.fetchall()

			cursor.execute("SELECT id_mode, name FROM cisco_modes")
			modes = cursor.fetchall()

		selected = {
			'id_table': None,
			'id_mode': None
		}

		selected['id_mode'] = int(request.args.get('mode')) if request.args.get('mode') != None else -1

		if request.method == 'POST':
			data = []

			try:
				for i in range(0, count_elements):
					data.append({
						'id_command': None,
						'id_table': int(request.form['id_table']),
						'command': request.form['command_'+str(i)],
						'id_mode': int(request.form['id_mode_'+str(i)]),
						'description': None if not request.form['description_'+str(i)] else str(request.form['description_'+str(i)])
					})

				selected['id_table'] = data[0]['id_table']

				with mysql.connection.cursor() as cursor:
					for i in range(0, len(data)):
						cursor.execute("INSERT INTO `commands` (id_command, id_table, command, mode, description) VALUES (%s, %s, %s, %s, %s)",
							(data[int(i)]['id_command'], data[int(i)]['id_table'], data[int(i)]['command'], data[int(i)]['id_mode'], data[int(i)]['description'],)
						)
						mysql.connection.commit()
						message = 'Команда(-ы) добавлена(-ы)'
			except:
				message = Markup('<b>Произошла ошибка</b> <br> {0}'.format(sys.exc_info()[1]) + '<br>')

		return render_template('admin/commandAdd.html', table=tables, mode=modes, message=message, data1=selected, count_elements=count_elements)

	else:
		return render_template('admin/video.html')

@app.route("/admin/sectionAdd", methods=['POST', 'GET'])
def sectionAdd():

	if session['auth'] == 1:

		mysql.connection.ping()

		message = ''

		if request.method == 'POST':
			data = {
				'id_section': None,
				'name': request.form['name'],
				'name_ru': request.form['name_ru'],
				'href': None if not request.form['href'] else str(request.form['href'])
			}
			try:
				with mysql.connection.cursor() as cursor:
					cursor.execute("INSERT INTO section (id_section, name, name_ru, href) VALUES (%s, %s, %s, %s)",
						(data['id_section'], data['name'], data['name_ru'], data['href'],)
					)
					mysql.connection.commit()
					message = 'Раздел "{0} - {1}" добавлена'.format(data['name'], data['name_ru'])
			except:
				message = 'Произошла ошибка: {0}'.format(sys.exc_info()[1])

		return render_template('admin/sectionAdd.html', message=message)

	else:
		return render_template('admin/video.html')

@app.route("/admin/subsectionAdd", methods=['POST', 'GET'])
def subsectionAdd():

	if session['auth'] == 1:

		mysql.connection.ping()
		with mysql.connection.cursor() as cursor:

			cursor.execute("SELECT id_section, name FROM section")
			sections = cursor.fetchall()

		message = ''

		if request.method == 'POST':
			data = {
				'id_subsection': None,
				'id_section': None if int(request.form['id_section']) == 0 else int(request.form['id_section']),
				'name': request.form['name'],
				'name_ru': request.form['name_ru'],
				'href': None if not request.form['href'] else str(request.form['href'])
			}
			try:
				with mysql.connection.cursor() as cursor:
					cursor.execute("INSERT INTO subsection (id_subsection, id_section, name, name_ru, href) VALUES (%s, %s, %s, %s, %s)",
						(data['id_subsection'], data['id_section'], data['name'], data['name_ru'], data['href'],)
					)
					mysql.connection.commit()
					message = 'Подраздел "{0} - {1}" добавлена'.format(data['name'], data['name_ru'])
			except:
				message = 'Произошла ошибка: {0}'.format(sys.exc_info()[1])


		return render_template('admin/subsectionAdd.html', section=sections, message=message)

	else:
		return render_template('admin/video.html')