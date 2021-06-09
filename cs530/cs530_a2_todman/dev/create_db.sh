#!/bin/sh

# McWelling H Todman, mht47@drexel.edu
# CS530: DUI, Assignment [2]

sqlite3 bikes.db << 'EVENT'
CREATE TABLE IF NOT EXISTS bikes (
    id TEXT PRIMARY KEY
    ,name TEXT NOT NULL
    ,wheels INTEGER
    ,size INTEGER
    ,motor INTEGER
    ,folding INTEGER
    ,image TEXT
    ,available INTEGER
);
.mode csv
.import bikes.csv bikes
EVENT