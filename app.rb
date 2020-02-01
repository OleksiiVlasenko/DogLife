require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def add_db
     @db = SQLite3::Database.new('.\public\doglife.db')
    @db.results_as_hash = true
    return @db
end

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
     @db.execute ('CREATE TABLE if not exists "Comments" (
    "id"  INTEGER PRIMARY KEY AUTOINCREMENT,
    "comment"  TEXT,
    "post_id"  TEXT
    );') 
  enable :sessions
end

  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
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
  @db = add_db
  topic = params['topic']
  date  = params['date']
  body  = params['body']
  photo = params['photo']

  @db.execute("insert into Blog(topic,date,body,photo) values(?,?,?,?)",[topic,date,body,photo])
  @db.close
  erb :blog
end

get "/comment/:post_id" do
  @db = add_db
  post_id = params[:post_id]
  result = @db.execute'select * from Blog where id = ?',[post_id]
  @row = result[0]
  @db.close
  erb :comment
end


post "/comment/:post_id" do
  @db = add_db
  post_id = params[:post_id]
  comment = params['comment']
  @db.execute("insert into Comments(comment,post_id) values(?,?)",[comment,post_id])
  
  @db.close
  erb :blog
end

get '/admin' do
  erb :admin
end

