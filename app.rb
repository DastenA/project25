require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get ('/') do
    slim(:start)
end

get ('/card') do 
    db = SQLite3::Database.new("db/cards.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    p result
    slim(:"card",locals:{cards:result})

end

get ('/card/:name') do 
    db = SQLite3::Database.new("db/cards.db")
    db.results_as_hash = true
    result = db.execute("SELECT card_name FROM cards")
    name = params[:name]
    id = params[:id]
    slim(:character)
end

get ('/collection') do
    slim(:collection)
end

get ('/login') do

    slim(:login)
end

post('/users_new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]


    if password == password_confirm
        #lägg till användare
        password_digest = BCrypt::Password.create(password)
        db= SQLite3::Database.new('db/cards.db')
        db.execute("INSERT INTO users (username,password) VALUES (?,?)",[username,password_digest])
        redirect('/')
    
    else
        p "Lösenorden matchade inte"
    end

end

post('/login') do 
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/cards.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    password = result["password"]
    id = result["user_id"]
  
    if BCrypt::Password.new(password) == password

      session[:user_id] = id
      session[:username] = username

      redirect('/')
    else
      "Fel lösenord"
    end
end
  