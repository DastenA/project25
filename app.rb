require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:start)
end

get('/card') do 
    db = SQLite3::Database.new("db/cards.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards")
    slim(:"card/index",locals:{cards:result})

end

get('/collection') do
    slim(:collection)
end

post('/card/:id/update') do
    id = params[:id].to_i
    card_name = params[:card_name]
    card_series = params[:card_series]
    card_value = params[:card_value].to_i
    db = SQLite3::Database.new("db/cards.db")
    db.execute("UPDATE cards SET card_name=?,card_series=?,card_value=? WHERE card_id = ?",[card_name,card_series,card_value,id])
    redirect('/card')
    
end

get('/card/:id/edit') do 
    id = params[:id].to_i
    db = SQLite3::Database.new("db/cards.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM cards WHERE card_id = ?",id).first
    p result
    slim(:"/card/edit", locals:{result:result})
  end



get('/card/new') do
    slim(:"card/new")
end


post('/card/new') do
    card_name = params[:card_name]
    card_series = params[:card_series]
    card_value = params[:card_value].to_i
    image_url = params[:img_url]

    db = SQLite3::Database.new('db/cards.db')
    db.execute("INSERT INTO cards (card_name,card_series,card_value,image_url) VALUES (?,?,?,?)",[card_name,card_series,card_value,image_url])
    redirect('/card')
end


get('/account') do
    slim(:account)
end

post('/create_account') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if password == password_confirm
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/cards.db')
        db.execute("INSERT INTO users (username,password) VALUES (?,?)",[username,password_digest])
        redirect('/account')
    else
        "PASSWORD DOES NOT FIT"
    end

end

post('/log_in_account') do 
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
