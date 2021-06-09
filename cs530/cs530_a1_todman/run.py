# McWelling H Todman, mht47@drexel.edu
# CS530: DUI, Assignment [1]

import os
import json

from flask import Flask, g, json, render_template, request

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('home.html')


@app.route('/about')
def about():
    return render_template('about.html')


@app.route('/bikes')
def bikes():
    # copies data into a json formatted file, passes to render template
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


if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
