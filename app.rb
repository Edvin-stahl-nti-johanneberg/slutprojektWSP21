require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require "byebug"



enable :sessions

get('/') do
    slim(:register)

    
  end
  
  get('/showlogin') do
    slim(:login)
  end
  
  post('/login') do
    username = params[:username]
    password_from_form = params[:password]
    db = SQLite3::Database.new ('db/databas.db ')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    password_from_db = result["password"]
    id = result["id"]
  
    if BCrypt::Password.new(password_from_db) == password_from_form
      session[:id] = id 
      redirect('/produkt')
    else
      "wrong"
    end
  end 
  
  get('/produkt') do
    id = session[:id].to_i
    db = SQLite3::Database.new ('db/databas.db ')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM produkt")
    p "alla todos #{result}"
    slim(:"produkt/produkt",locals:{produkt:result})
  end
  
  
  post("/users/new") do
  username = params[:username]
  password_from_form = params[:password]
  password_comfirm = params[:password_comfirm]

    if (password_from_form == password_comfirm)
      p "Det stämmer"
      password_digest=BCrypt::Password.create(password_from_form)
      p "pwdigest är #{password_digest}"
      db = SQLite3::Database.new("db/databas.db")
      db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_digest)
      p "vi skickas tillbaks"
      redirect("/")
    else
      "fel lösenord"
    end
  end

