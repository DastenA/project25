require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
#require 'becrypt'

enable :sessions

get ('/') do
    slim(:start)
end

post ('/') do 

end

get ('/card') do 
    db = SQLite3::Database.new("db/cards.db")
    slim(:card)
end

get ('/collection') do
    slim(:collection)
end