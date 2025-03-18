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

get ('/account') do

    slim(:account)
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if password == password_confirm
        #lägg till användare
        password_digest = BCrypt::Password.create(password)
        db= SQLite3::Database.new('db/cards.db')
        db.execute("INSERT INTO users (username,password) VALUES (?,?)",[username,password_digest])
        redirect('/account')
    else
        "PASSWORD DOES NOT FIT"
    end

end

post('/account') do 
    username = params[:username]
    password_check = params[:password]

    db = SQLite3::Database.new('db/cards.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    password = result["password"]
    user_id = result["user_id"]
  
    if BCrypt::Password.new(password) == password_check

      session[:username] = username

      redirect('/account')
    else
      "WRONG PASSWORD"
    end
end
  