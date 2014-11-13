require "rubygems"
require "sequel"
require 'sqlite3'

# connect to an in-memory database
DB = Sequel.sqlite

# create an items table
DB.create_table :items do
  primary_key :id
  String :name
  Float :price
  Float :time
end

# create a dataset from the items table
items = DB[:items]

# populate the table
items.insert(:name => 'abc', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'def', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'ghi', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'jkl', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'mnop', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'qrs', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'tuv', :price => rand * 100, :time => Time.now.getutc)
items.insert(:name => 'wxy', :price => rand * 100, :time => Time.now.getutc)
# print out the number of records
puts "Item count: #{items.count}"

puts "Average time is: #{items.avg(:time)}"



result = items.time.find(:name, :order => "id desc", :limit => 5)

while !result.empty?
        puts result.pop
end







my_posts = DB[:time].filter(:name => 'abc')
puts "test print out #{my_posts}"




# print out the average price
puts "The average price is: #{items.avg(:price)}"
