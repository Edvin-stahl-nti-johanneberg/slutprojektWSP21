require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'



enable :sessions

get('/') do
    slim(:register)
  end
  
  get('/showlogin') do
    slim(:login)
  end
  
  post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new ('db/databas.db ')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    password = result["password"]
    id = result["id"]
  
    if BCrypt::Password.new(password) == password
      session[:id] = id 
      redirect('/todos')
    else
      "fel"
    end
  end 
  
  get('/todos') do
    id = session[:id].to_i
    db = SQLite3::Database.new ('db/databas.db ')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM todos WHERE user_id = ?",id).first
    p "alla todos #{result}"
    slim(:"todos/index",locals:{todos:result})
  end
  
  
  post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_comfirm = params[:password_comfirm]
  
    if (password == password_comfirm)
      password_digest=BCrypt::Password.create(password)
      db = SQLite3::Database.new ("db/databas.db ")
      db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_digest)
      redirect("/")
    else
      "fel lösenord"
    end
  end
