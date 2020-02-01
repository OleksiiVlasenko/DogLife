require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def add_db
  return db = SQLite3::Database.new('.\public\doglife.db')
  # return db.results_as_hash = true
end
configure do
  configure do
  @db = add_db
    @db.execute ('CREATE TABLE if not exists "Users" (
    "id"  INTEGER PRIMARY KEY AUTOINCREMENT,
    "name"  TEXT,
    "pass"  TEXT,
    "role"  TEXT
    );')  
    @db.execute ('CREATE TABLE if not exists "Blog" (
    "id"  INTEGER PRIMARY KEY AUTOINCREMENT,
    "topic"  TEXT,
    "date"  TEXT,
    "body"  TEXT,
    "photo"  TEXT
    );') 
  enable :sessions
end
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :blog
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end


get '/newpost' do
  erb :newpost
end

post '/newpost' do
  
  
  topic = params['topic']
  date  = params['date']
  body  = params['body']
  photo = params['photo']

  @db.execute("insert into Blog(topic,date,body,photo) values(?,?,?,?)",[topic,date,body,photo])
  @db.close
  erb :blog
end