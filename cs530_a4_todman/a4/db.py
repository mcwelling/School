#   McWelling H Todman, mht47@drexel.edu
#   CS530: DUI, Assignment [4]

from index import Index


class Database:
    
    # mapping methods from Index class to Database
    def __init__(self, path):
        self.conn = Index(path)

    def is_empty(self):
        c = self.conn.is_empty()
        return c

    def populate(self, items, text_fields):
        self.conn.populate(items, text_fields)

    def get(self, **kwargs):
        c = self.conn.get(**kwargs)
        return c

    def search(self, query, field, n=10, join='and', avoid=None):
        c = self.conn.search(query, field, n, join, avoid)
        return c

    """
    def __init__(self, path):
        self.conn = sqlite3.connect(path)

    def select(self, sql, parameters=[]):
        c = self.conn.cursor()
        c.execute(sql, parameters)
        return c.fetchall()

    def execute(self, sql, parameters=[]):
        c = self.conn.cursor()
        c.execute(sql, parameters)
        self.conn.commit()

    def get_goats(self, n, offset):
        data = self.select(
            'SELECT * FROM goats ORDER BY id ASC LIMIT ? OFFSET ?', [n, offset])
        return [{
            'id': d[0],
            'name': d[1],
            'age': d[2],
            'adopted': d[3],
            'image': d[4]
        } for d in data]

    def get_user_goats(self, user_id):
        data = self.select(
            'SELECT * FROM goats WHERE adopted=? ORDER BY id ASC', [user_id])
        return [{
            'id': d[0],
            'name': d[1],
            'age': d[2],
            'adopted': d[3],
            'image': d[4]
        } for d in data]

    def get_num_goats(self):
        data = self.select('SELECT COUNT(*) FROM goats')
        return data[0][0]

    def update_goat(self, id, adopted):
        self.execute('UPDATE goats SET adopted=? WHERE id=?', [adopted, id])

    def create_user(self, name, username, encrypted_password):
        self.execute('INSERT INTO users (name, username, encrypted_password) VALUES (?, ?, ?)',
                     [name, username, encrypted_password])

    def get_user(self, username):
        data = self.select(
            'SELECT * FROM users WHERE username=?', [username])
        if data:
            d = data[0]
            return {
                'id': d[0],
                'name': d[1],
                'username': d[2],
                'encrypted_password': d[3],
            }
        else:
            return None

    def close(self):
        self.conn.close()
    
    """
