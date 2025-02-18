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

get ('/collection') do
    slim(:collection)
end

get ('/login') do
    slim(:login)
end