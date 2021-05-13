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
    p "password #{result}"
    password_from_db = result["password"]
    id = result["id"]
  
    if BCrypt::Password.new(password_from_db) == password_from_form
      session[:id] = id 
      redirect('/produkt')
    else
      "wrong"
    end
  end 
  #anropar databas om produkt
  get('/produkt') do
    id = session[:id].to_i
    db = SQLite3::Database.new ('db/databas.db ')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM produkt Where user_id = #{id} ")
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

# Get product
get('/produkt/:id') do
  session_id = session[:id]
  
  if session_id == nil
    redirect('/login')
    return
  end

  id = params[:id]
  db = SQLite3::Database.new ('db/databas.db ')
  result =  db.execute("SELECT * FROM produkt WHERE id = ?", id)
  slim(:"produkt/produkt", locals: { produkt: result[0] })
end

# Delete product
delete('/produkt/:id') do
  session_id = session[:id]
  
  if session_id == nil
    redirect('/login')
    return
  end

  id = params[:id]
  db = SQLite3::Database.new ('db/databas.db ')
  db.execute("DELETE FROM produkts WHERE id = ?", id)
  redirect('/')
end

# Update product
put('/produkt/:id') do
  session_id = session[:id]
  
  if session_id == nil
    redirect('/login')
    return
  end

  id = params[:id]
  db = SQLite3::Database.new ('db/databas.db ')
  titel = params[:titel]
  besk = params[:beskrivning]
  pris = params[:pris]

  db.results_as_hash = true
  result = db.execute("UPDATE produkts SET content=? WHERE id=?", todo, id).first
  redirect('/')
end

# Create new product
post('/produkt') do
  session_id = session[:id]
  
  if session_id == nil
    redirect('/login')
    return
  end
  db = SQLite3::Database.new ('db/databas.db ')
  titel = params[:titel]
  besk = params[:beskrivning]
  pris = params[:pris]
  db.results_as_hash = true
  db.execute("INSERT INTO produkt (titel, beskrivning, pris, user_id) VALUES (?,?,?,?)", titel, besk, pris, session_id)
  redirect('/produkt')
end

