require 'sinatra'
require 'httparty'
#require 'debugger'
require 'multi_json'
require 'serialport'
require "rubygems"
require "sequel"
require 'sqlite3'

#set :port, 3000
#setup serial
baud_rate = 57600
port_file = "/dev/ttyUSB0"
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE
port = SerialPort.new(port_file, baud_rate, data_bits, stop_bits, parity)


# https://github.com/aj0strow/sinatra-json_body_params
module Sinatra
  module JsonBodyParams

    def self.registered(app)
      app.before do
        params.merge! json_body_params
      end

      app.helpers do
        def json_body_params
          @json_body_params ||= begin
            MultiJson.load(request.body.read.to_s, symbolize_keys: true)
          rescue MultiJson::LoadError
            {}
          end
        end
      end
    end

  end
end

register Sinatra::JsonBodyParams

$i = ''
#$counter=0
$valueLight
$valueMotion
$valueFinger
$valueAvgLight
#$testingvalues = "i want to kill myself, why isnt this data base working to push to in the loop??"


#database setup

DB = Sequel.sqlite

# create an items table
DB.create_table :items do
  primary_key :id
  String :name
  Float :value
end

# create a dataset from the items table
items = DB[:items]

# populate the table
# items.insert(:name => 'abc', :value => 10000)

# print out the number of records
# puts "Item count: #{items.count}"

# puts "Average time is: #{items.avg(:value)}"
# $valueAvgLight = items.avg(:value)

# puts "valueAvgLight : "
# puts $valueAvgLight


$string
Thread.new do
  while true do
    $string = ''
   while ($i = port.gets) do
      #puts "$i : #{$i}" #String
      $string<< $i
      break
    end
    puts "$string : #{$string.dump}"
    puts "$string.length : #{$string.length}"
    key, value = $string.split ': ', 2
    puts key
    puts value
    if (key.eql? "Light")
        $valueLight = value
        items.insert(:name => 'abc', :value => value)
        $valueAvgLight = items.avg(:value)
        puts "valueAvgLight : "
        puts $valueAvgLight
    end
    if (key.eql? "Finger")
        #put "Finger: "
        $valueFinger = value
        #put $valueFinger
    end
    if (key.eql? "Motion")
        #put "Motion: "
        $valueMotion = value
        #put $val
    end

    # if ($string.eql?  "this is a test\n")
    #   puts "comparison worked"
    #   $counter +=1
    #   puts "counter changes"
    #   puts "$counter : #{$counter}"
    # end
    # if (key.eql? "Light")
    # end

    sleep 0.5
  end
end


  # SERVER
  post "/email_processor" do
     command = params[:Subject].downcase
     if command == "status"
        if ($valueMotion.eql? "1\r\n")
          $motionBackground = "green"
        else
          $motionBackground ="red"
        end
        #change text when lighter color
        if ($valueLight.to_i > 170)
          $textColor = "black"
        else
          $textColor = "white"
        end

        HTTParty.post("http://api.mailjet.com/v3/send/message", 
          :body => {to: params[:From], from: "tmhall1@pipeline.sbcc.edu", 
          subject: "WiPi - Current Condition of Nodes", 
          html: "
          <html>
            <img src=\"http://i.imgur.com/LeUHoyR.png\"/>
            <div style=\"font: 35px; margin: 25px; float: left;width: 200px; line-height: 200px; height: 200px; color: white;  background: blue; -moz-border-radius: 10px;
-webkit-border-radius: 10px;
border-radius: 10px; /* future proofing */
-khtml-border-radius: 10px; /* for old Konqueror browsers */\">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Finger Value : #{$valueFinger} <br> 
            </div>
            <div style=\"font: 20px; margin: 25px; float: left;width: 200px; line-height: 200px; height: 200px; color: white;  background: #{$motionBackground}; -moz-border-radius: 10px;
-webkit-border-radius: 10px;
border-radius: 10px; /* future proofing */
-khtml-border-radius: 10px; /* for old Konqueror browsers */\">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Motion : #{$valueMotion} <br>
            </div>
            <div style=\"font: 20px; margin: 25px; float: left;width: 200px; line-height: 200px; height: 200px; color: white;  background-color: rgb(#{$valueLight},#{$valueLight},#{$valueLight}); -moz-border-radius: 10px;
-webkit-border-radius: 10px;
border-radius: 10px; /* future proofing */
-khtml-border-radius: 10px; /* for old Konqueror browsers */\">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Light: #{$valueLight} <br>
            </div>
            <div style=\"font: 20px; margin: 25px; float: left;width: 200px; line-height: 200px; height: 200px; color: white;  background-color: rgb(#{$valueLight},#{$valueLight},#{$valueLight}); -moz-border-radius: 10px;
-webkit-border-radius: 10px;
border-radius: 10px; /* future proofing */
-khtml-border-radius: 10px; /* for old Konqueror browsers */\">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Light Average (since node start): #{$valueAvgLight} <br>
            </div>

          </html>"}, 

          :basic_auth => {username: "67277d9381e70cac1ea98102a9463bf3", password: "d26319db8e691bfc47a7efb88ef7d560"})
        puts "sent"
     end
     if (command == "flash")
       port.write "f"
     end
  end



#advanced {

