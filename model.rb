require 'sqlite3'
require 'bcrypt'

#/gör om koden till hash 
def connect()
    db = SQLite3::Database.new ('db/db.db ')
    db.results_as_hash = true
    return db
end

def varukorg()
    varukorg = connect().execute("INSERT INTO")
end
