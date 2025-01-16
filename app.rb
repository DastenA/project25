require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
#require 'becrypt'

enable :sessions

get ('/word') do
    slim(:temp)
end