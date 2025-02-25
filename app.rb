require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get ('/') do
    slim(:start)
end

post ('/') do 

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

post ('/login') do 
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/cards.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
        
    redirect('/')
    else
    "Fel lösenord"
    end
end