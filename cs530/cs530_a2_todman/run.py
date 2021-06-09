# McWelling H Todman, mht47@drexel.edu
# CS530: DUI, Assignment [2]

import os
import json
import sqlite3

from flask import Flask, g, json, jsonify, render_template, request

from db import Database

app = Flask(__name__)

DATABASE_PATH = 'bikes.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = Database(DATABASE_PATH)
    return db

@app.teardown_appcontext
def close_db(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/rent')
def rent():
    return render_template('rent.html')

# holdover from A1
@app.route('/bikes')
def bikes():
    with open('data/data.txt','r') as app_data:
        bike_data = app_data.read()
        with open('temp.json', 'w') as temp:
            temp.write('{"data": [' + str(bike_data) + ']}')
            temp.close()
        app_data.close()
    
    temp_data = open('temp.json', 'rb')
    bike_data = json.load(temp_data)
    temp_data.close()
    os.remove('temp.json')

    return render_template('bikes.html', data = bike_data)

# response formatter for api calls
def generate_response(args):
    n = args.get('n', default=10)
    return jsonify(get_db().get_bikes(n))


# api router for base bike inventory query
@app.route('/api/get_bikes', methods=['GET'])
def api_get_bikes():
    return generate_response(request.args)

# api router for bike inventory changes (+/-)
@app.route('/api/update_bike', methods=['POST'])
def api_update_bike():
    id = request.form.get('id')
    available = request.form.get('available')
    get_db().update_bike(id, available)
    return generate_response(request.form)

# api router for bike inventory reset
@app.route('/api/reset_bikes', methods=['POST'])
def api_reset_bikes():
    available = request.form.get('available')
    get_db().reset_bikes(available)
    return generate_response(request.form)

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
