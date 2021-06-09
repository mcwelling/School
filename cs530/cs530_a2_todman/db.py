# McWelling H Todman, mht47@drexel.edu
# CS530: DUI, Assignment [2]

import sqlite3


class Database:

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

    # query to return all columns for n bikes in database
    def get_bikes(self, n):
        data = self.select(
            'SELECT * FROM bikes ORDER BY id ASC LIMIT ?', [n])
        return [{
            'id': d[0]
            ,'name': d[1]
            ,'wheels': d[2]
            ,'size': d[3]
            ,'motor': d[4]
            ,'folding': d[5]
            ,'image': d[6]
            ,'available': d[7]
        } for d in data]

    # query to update inventory count for bike by unique id
    def update_bike(self, id, available):
        self.execute('UPDATE bikes SET available = available + ? WHERE id = ?', [available, id])

    # query to reset inventory count for all bikes
    def reset_bikes(self, available):
        self.execute('UPDATE bikes SET available = ?', [available])

    def close(self):
        self.conn.close()
