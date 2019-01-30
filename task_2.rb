require 'discordrb'
require 'rmagick'
require '/home/daburutti/DKC_bot/image_task.rb'
require 'steam-condenser'
require 'json'
require 'open-uri'
require 'rest-client'
require 'net/http'
require 'uri'
require 'mini_magick'

ltid = 0

file = File.open("/home/daburutti/DKC_bot/id")
file.each do |a|
 ltid = a.to_i
end
file.close

@bot = Discordrb::Commands::CommandBot.new token: '', client_id: , prefix: '!'

sleep(3)

def start_typing(token, channel_id)
    Discordrb::API.request(
      :channels_cid_typing,
      channel_id,
      :post,
      "#{Discordrb::API.api_base}/channels/#{channel_id}/typing",
      nil,
      Authorization: token
    )
end

key = "[JP]FRIENDS"

#input = gets
APIKEY = "50A39519488BF3EC64B3463BEC71BCC0"
#MatchServerName = input.chomp!

STEMAIDOFFSET = 76561197960265728

Jsondata_serch_Matches = "http://logs.tf/api/v1/log?title=#{URI.encode key}"

uri = URI.parse(Jsondata_serch_Matches)
json =  Net::HTTP.get(uri)

json_pars = JSON.parse(json)

number = "0"

if json_pars["logs"].length >= 1000 then
    number = "1000件以上"
else
    number = "#{json_pars["logs"].length}件"
end
matchID = 0
begin
    matchID = json_pars["logs"][0]["id"]
rescue => exception
    event.send_message "マッチが見つかりませんでした"
    exit
end
#puts json_pars["logs"]

if ltid == matchID then
    return
end
start_typing()


matchdata = "http://logs.tf/json/#{matchID}"

#TESTURL = "http://logs.tf/json/2127732"

uri = URI.parse(matchdata)

json =  Net::HTTP.get(uri)
json_pars = JSON.parse(json)
title = json_pars["info"]["title"]
map = json_pars["info"]["map"]
date = Time.at(json_pars["info"]["date"])

score_red = json_pars["teams"]["Red"]["score"]
score_blu = json_pars["teams"]["Blue"]["score"]

puts "title:#{title}"
puts "map:#{map}"
puts "date:#{date}"

puts "match result RED:#{score_red} BLU:#{score_blu}"
begin
#三次元配列の初期化
data = Hash.new { |hash,key| hash[key] = Hash.new { |hash,key| hash[key] = {} } }

data["TOPKILL"][0]["name"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[0][0]
data["TOPKILL"][0]["point"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[0][1]["kills"]

data["TOPKILL"][1]["name"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[1][0]
data["TOPKILL"][1]["point"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[1][1]["kills"]

data["TOPKILL"][2]["name"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[2][0]
data["TOPKILL"][2]["point"] = json_pars["players"].sort_by {| a,b | b["kills"].to_i}.reverse[2][1]["kills"]



data["TOPASSIST"][0]["name"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[0][0]
data["TOPASSIST"][0]["point"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[0][1]["assists"]

data["TOPASSIST"][1]["name"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[1][0]
data["TOPASSIST"][1]["point"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[1][1]["assists"]

data["TOPASSIST"][2]["name"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[2][0]
data["TOPASSIST"][2]["point"] = json_pars["players"].sort_by {| a,b | b["assists"].to_i}.reverse[2][1]["assists"]

#Deatshs


data["TOPDEATHS"][0]["name"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[0][0]
data["TOPDEATHS"][0]["point"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[0][1]["deaths"]

data["TOPDEATHS"][1]["name"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[1][0]
data["TOPDEATHS"][1]["point"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[1][1]["deaths"]

data["TOPDEATHS"][2]["name"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[2][0]
data["TOPDEATHS"][2]["point"] = json_pars["players"].sort_by {| a,b | b["deaths"].to_i}.reverse[2][1]["deaths"]

#data["MEDICS"][0]["name"] = json_pars["players"].sort_by {| a,b | b["medicstats"]}.reverse[0][0]

num = 0

steamid = ""

json_pars["players"].each_key{|key|
    if json_pars["players"][key]["medicstats"] != nil then

        data["MEDICS"][num.to_i]["name"] = key
        data["MEDICS"][num.to_i]["team"] = json_pars["players"][key]["team"]
        data["MEDICS"][num.to_i]["heal"] = json_pars["players"][key]["heal"]
        data["MEDICS"][num.to_i]["drops"] = json_pars["players"][key]["drops"]
        data["MEDICS"][num.to_i]["ubers"] = json_pars["players"][key]["ubers"]
        num = num.to_i + 1
    end
    steamid = key.match(/U:1:(.+)\]/)

    steamid64 = steamid[1].to_i + STEMAIDOFFSET


    url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{APIKEY}&steamids=#{steamid64}"
    uri = URI.parse(url)

    json =  Net::HTTP.get(uri)
    json_id_pars = JSON.parse(json)

    imagedata =  json_id_pars["response"]["players"][0]["avatarfull"]
    # puts "GET:#{imagedata}"
    # open(imagedata, http_basic_authentication: ["", ""]) { |image|
    #     File.open("/home/daburutti/Test/#{key}.jpg","wb") do |file|
    #         file.puts image.read
    #     end
    # }
    #-size 200x200 xc:none -fill walter.jpg -draw "circle 100,100 100,1" circle_thumb.png

    # value = `convert -size 184x184 xc:none -fill \"/home/daburutti/Test/\[U\:1\:#{steamid[1]}\].jpg\" -draw \"circle 92,92 100,1\" \"/home/daburutti/Test/\[U\:1\:#{steamid[1]}\]_maru.png\"`
    # puts "IMAGE CONVERTED"
}

puts data

puts "START IMAGE FAZE"
files = Dir.glob("/var/www/html/tf2/demos/*.dem").sort_by{ |f| File.mtime(f) }.each do |file|
end

@bot.send_message(531503149371097108,"#{title}\nmap : #{map}\ndate  :#{date}\nDownload demo : http://www.dabudabu.net:8080/tf2/demos/#{File.basename(files[files.length - 1])}\nLOG:https://logs.tf/#{matchID}")

rescue => exception
    @bot.send_message(531503149371097108,"#{title} map : #{map} date : #{date}\nDownload demo : http://www.dabudabu.net:8080/tf2/demos/#{File.basename(files[files.length - 1])}\nLOG:https://logs.tf/#{matchID}")

end


puts File.basename(files[files.length - 1])

File.open("/home/daburutti/DKC_bot/id","w") do | b |
    b.print(matchID)
end