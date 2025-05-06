require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

before do
  @is_admin = session[:role] == "admin"
  @error = session.delete(:error)

  protected_routes_user = [ %r{^/card/\d+/edit$}, %r{^/card/\d+/remove$}, %r{^/card/\d+/update$}, %r{^/card/\d+/delete$}, %r{^/card/new$}
  ]
  protected_routes_admin = [%r{^/admin$}]

  if protected_routes_user.any? { |route| request.path_info.match(route) } && session[:user_id].nil?
    session[:error] = "Du måste vara inloggad för att komma åt denna sida."
    redirect '/account'
  end

  if protected_routes_admin.any? { |route| request.path_info.match(route) } && !@is_admin
    session[:error] = "Endast administratörer har åtkomst till denna sida."
    redirect '/account'
  end
end

def connect_to_db(path)
  db = SQLite3::Database.new(path)
  db.results_as_hash = true
  db
end

get('/') { slim(:start) }

get('/card') do
  db = connect_to_db('db/cards.db')
  cards = db.execute("SELECT * FROM cards")
  slim(:"card/index", locals: { cards: cards })
end

get('/collection') { slim(:collection) }

get('/card/:id/edit') do
  id = params[:id].to_i
  db = connect_to_db('db/cards.db')
  result = db.execute("SELECT * FROM cards WHERE card_id = ?", id).first
  slim(:"/card/edit", locals: { result: result })
end

post('/card/:id/update') do
  id = params[:id].to_i
  name = params[:card_name]
  series = params[:card_series]
  value = params[:card_value].to_i

  db = connect_to_db('db/cards.db')
  db.execute("UPDATE cards SET card_name=?, card_series=?, card_value=? WHERE card_id=?",
             [name, series, value, id])
  redirect('/card')
end

get('/card/:id/remove') do
  id = params[:id].to_i
  db = connect_to_db('db/cards.db')
  result = db.execute("SELECT * FROM cards WHERE card_id = ?", id).first
  slim(:"/card/delete", locals: { result: result })
end

post('/card/:id/delete') do
  id = params[:id].to_i
  db = connect_to_db('db/cards.db')
  db.execute("DELETE FROM cards WHERE card_id = ?", id)
  redirect('/card')
end

get('/card/new') { slim(:"card/new") }

post('/card/new') do
  name = params[:card_name]
  series = params[:card_series]
  value = params[:card_value].to_i
  image = File.basename(params[:image_url]) # Prevent path traversal

  db = connect_to_db('db/cards.db')
  db.execute("INSERT INTO cards (card_name, card_series, card_value, image_url) VALUES (?, ?, ?, ?)",
             [name, series, value, "./img/#{image}"])
  redirect('/card')
end

get('/account') do
  slim(:account, locals: { error: @error })
end

post('/create_account') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = connect_to_db('db/cards.db')
    db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password_digest])
    redirect('/account')
  else
    session[:error] = "Lösenorden matchar inte."
    redirect('/account')
  end
end

post('/log_in_account') do 
    username = params[:username]
    password_input = params[:password]
  
    db = connect_to_db('db/cards.db')
    user = db.execute("SELECT * FROM users WHERE username = ?", username).first
  
    if user && BCrypt::Password.new(user["password"]) == password_input
      session[:username] = username
      session[:user_id] = user["user_id"]
      session[:role] = user["role"] || "user"
      redirect('/account')
    else
      session[:error] = "Fel användarnamn eller lösenord."
      redirect('/account')
    end
  end
  
