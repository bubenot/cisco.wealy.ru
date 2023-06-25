from cwr import app, settings

if __name__ == "__main__":
	app.run(debug=settings['flask']['debug'])
