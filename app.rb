require 'rubygems'
require 'sinatra'
require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/app.db")

enable :sessions
use Rack::Session::Cookie

class Item
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :completed, Boolean, :required => true, :default => false
  property :list, Integer, :required => true
  property :owner, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

class List 
  include DataMapper::Resource
  property :id, Serial
  property :title, Text, :required => true
  property :owner, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Owner
  include DataMapper::Resource
  property :id, Serial
  property :cookie, Text, :required => true
  property :first_name, Text
  property :last_name, Text
  property :email, Text
  property :created_at, DateTime
  property :updated_at, DateTime
end

Item.auto_migrate! unless Item.storage_exists?
List.auto_migrate! unless List.storage_exists?
Owner.auto_migrate! unless Owner.storage_exists?

def generate_random_string(length=6)
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
  string = ''
  length.times { |i| string << chars[rand(chars.length)] }
  string
end

get '/' do
  #set owner ID
  @owner = request.cookies["owner"]
  if !@owner
    @owner = generate_random_string(12)
    response.set_cookie('owner', :value => @owner, :expires => Time.now + 360000000, :path => '/')
  end
  @lists = List.all(:owner => @owner, :order => :id.asc)
  @items = Item.all(:owner => @owner, :order => :id.asc)
  erb :index
end

get '/owner/:owner' do
  response.set_cookie('owner', :value => nil, :expires => Time.now - 1000, :path => '/')
  response.set_cookie('owner', :value => params[:owner], :expires => Time.now + 360000000, :path => '/')
  redirect '/'
end

#add an item to your list
post '/item' do
  n = Item.new  
  n.content = params[:content] 
  n.list = params[:list] 
  n.owner = request.cookies["owner"]
  n.created_at = Time.now  
  n.updated_at = Time.now  
  n.save
  redirect '/'
end

#add a list
post '/list' do
  n = List.new  
  n.title = params[:title]  
  n.owner = request.cookies["owner"]
  n.created_at = Time.now  
  n.updated_at = Time.now  
  n.save
  redirect '/'
end

#update the item in your list
put '/item/:id' do  
  i = Item.get params[:id]  
  i.completed = i.completed ? 0 : 1
  i.updated_at = Time.now  
  i.save  
  redirect '/'
end  

#remove the item in your list
delete '/item/:id' do  
  i = Item.get params[:id]  
  i.destroy  
  redirect '/'
end  

delete '/list/:id' do  
  i = List.get params[:id]  
  i.destroy  
  redirect '/'
end  