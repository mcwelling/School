#   McWelling H Todman, mht47@drexel.edu
#   CS530: DUI, Assignment [4]


from flask import (Flask, g, jsonify, redirect, render_template, request,
                   session)
from passlib.hash import pbkdf2_sha256

from db import Database
import json

INDEX_PATH = 'index'

DATABASE_PATH = 'dev/orgs.json'

app = Flask(__name__)
app.secret_key = b'demo_key_not_real!'

# generate and load data into index
def get_db():
    db = None #getattr(g, '_database', None)
    if db is None:
        db = Database(INDEX_PATH)
        inputFile = open(DATABASE_PATH)
        indexData = json.load(inputFile)
        db.populate(indexData,['mission'])
        inputFile.close()
    return db


@app.teardown_appcontext
def close_db(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


@app.route('/')
def home():
    return render_template('home.html')

@app.route('/view')
def view():
    # grab parameter from URL and pass to index, then include data in render template
    uid = request.args.get('uid', default=1)
    newIndex = get_db()
    viewResult = newIndex.get(uid=uid)
    return render_template('view.html', pageData = viewResult)

# api search functionality for home page
@app.route('/api/search', methods=['GET'])
def api_search():
    query = request.args.get('query', default='')
    myIndex = get_db()
    result = myIndex.search(query, 'mission', 10, 'and')
    return jsonify(result)

# api functionality to get related organizations
@app.route('/api/related', methods=['GET'])
def api_related():
    relatedQuery = request.args.get('query', default='')
    relatedUID = request.args.get('uid', default='')
    relatedIndex = get_db()
    relatedResults = relatedIndex.search(relatedQuery, 'mission', 6, 'or', {'uid': relatedUID})
    print(relatedResults)
    return jsonify(relatedResults)


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')


if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
