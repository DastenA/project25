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
    slim(:"card",locals:{cards:result})

end

get ('/collection') do
    slim(:collection)
end

get ('/account') do

    slim(:account)
end

get ('/card_creation') do

    slim(:card_creation)
end

=begin
post ('/card_creation/new') 
    card_name = params[:card_name]
    card_series = params[:card_series]
    card_value = params[:card_value]
    img_url = params[:img_url]


    db = SQLite3::Database.new('db/cards.db')
    db.execute("INSERT INTO cards (card_name,card_series,card_value,img_url) VALUES (?,?,?,?)",[card_name,card_series,card_value,img_url])
    redirect('/card_creation')
end


post('/upload_image') do
    #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
    path = File.join("./public/uploaded_pictures/",params[:file][:filename])
    
    #Spara bilden (skriv innehållet i tempfile till destinationen path)
    File.write(path,File.read(params[:file][:tempfile]))
    
    redirect('/upload_image')
   end
=end

post ('/create_account') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if password == password_confirm
        #lägg till användare
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/cards.db')
        db.execute("INSERT INTO users (username,password) VALUES (?,?)",[username,password_digest])
        redirect('/account')
    else
        "PASSWORD DOES NOT FIT"
    end

end

post ('/log_in_account') do 
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
