require 'rubygems'
require 'sinatra'
require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/app.db")

class Item
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :completed, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end

Item.auto_migrate! unless Item.storage_exists?

get '/' do
  @items = Item.all :order => :id.desc 
  erb :list
end

#add an item to your list
post '/' do
  n = Item.new  
  n.content = params[:content]  
  n.created_at = Time.now  
  n.updated_at = Time.now  
  n.save
  redirect '/'
end

#update the item in your list
put '/:id' do  
  i = Item.get params[:id]  
  i.completed = i.completed ? 0 : 1
  i.updated_at = Time.now  
  i.save  
  redirect '/'
end  

#remove the item in your list

delete '/:id' do  
  i = Item.get params[:id]  
  i.destroy  
  redirect '/'
end  