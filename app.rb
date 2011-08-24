require 'rubygems'
require 'sinatra'
require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/app.db")

class Item
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :completed, Boolean, :required => true, :default => false
  property :list, Integer, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

class List 
  include DataMapper::Resource
  property :id, Serial
  property :title, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

Item.auto_migrate! unless Item.storage_exists?
List.auto_migrate! unless List.storage_exists?

get '/' do
  @lists = List.all :order => :id.asc
  @items = Item.all :order => :id.asc
  erb :index
end

#add an item to your list
post '/item' do
  n = Item.new  
  n.content = params[:content] 
  n.list = params[:list] 
  n.created_at = Time.now  
  n.updated_at = Time.now  
  n.save
  redirect '/'
end

#add an item to your list
post '/list' do
  n = List.new  
  n.title = params[:title]  
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