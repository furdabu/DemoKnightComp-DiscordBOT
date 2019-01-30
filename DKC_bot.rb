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
token =
@imagetask = ImageTask.new



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

@hotserverdata = Hash.new { |hash,key| hash[key] = Hash.new { |hash,key| hash[key] = {} } }
bot = Discordrb::Commands::CommandBot.new token: '', client_id:, prefix: '!'
bot.ready(){|event,game|
	bot.game = "KnightComp.JP"
	nil
    }
def Get_Server_Status(ip,port)
    begin
        @server = SourceServer.new(ip, port.to_i)
        @server.init
        serverdata = "#{@server}"

        player =  @server.players
        mapname = serverdata.match(/map_name: "(.+)"/)
        servername = serverdata.match(/server_name: "(.+)"/)
        maxplayer = serverdata.match(/max_players:\s(.+)/)
        players = serverdata.match(/number_of_players:\s(.+)/)
        bot = serverdata.match(/number_of_bots:\s(.+)/)
        tag = serverdata.match(/server_tags: "(.+)"/)
        ver = serverdata.match(/game_version: "(.+)"/)
        os = serverdata.match(/operating_system: "(.+)"/)

        servernamemeta = servername[1]

        mapname = mapname[1]

        if servernamemeta.length > 28 then
            servernamemeta = servernamemeta.slice(0, 29)
        end

        #trueplayer = players[1].to_i - bot[1].to_i
        trueplayer = players[1].to_i

    #puts server.players("0000")
    #puts server.players.to_json
    #puts server
        servername = servername[1]

        @hotserverdata[0]["servername"] = servername
        @hotserverdata[0]["player"] = trueplayer
        @hotserverdata[0]["maxplayer"] = maxplayer[1].to_i
        @hotserverdata[0]["ip"] = ip
        @hotserverdata[0]["port"] = port.to_i
        @hotserverdata[0]["mapname"] = mapname
        @hotserverdata[0]["tag"] = tag[1]
        @hotserverdata[0]["ver"] = ver[1]
        @hotserverdata[0]["os"] = os[1]

        puts @hotserverdata.to_json
    data = Hash.new { |hash,key| hash[key] = Hash.new { |hash,key| hash[key] = {} } }
    for x in 0...6 do
        data["Player"][x]["name"] = "-"
        data["Player"][x]["score"] = 0
        data["Player"][x]["time"] = 0
    end
    int = 0
    @server.players.each do |value , key|
        # key.to_s

        begin
            name = key.to_s.match(/#0 "(.+)\"/)[1]
        rescue
            name = "-Joining-"
        end
        begin
        score = key.to_s.match(/Score:\s(.+),/)[1]
    rescue => exception
        puts exception
        score = "-"
    end
        begin
        time = key.to_s.match(/Time:\s(.+)/)[1].to_i/60.round

    rescue
        time = "-"
    end

    if name.length > 17 then
        name = name.slice(0, 17)
        name = "#{name}..."
    end
        data["Player"][int]["name"] = name
        data["Player"][int]["score"] = score.to_i
        data["Player"][int]["time"] = time
        int = int + 1
        #puts key
    end
    puts data.to_json
    twstr = ""
    @imagetask.wow_such_a_hot_server(@hotserverdata,data)

    images = []
    images << File.new('./tweet.png')
end

end

bot.member_join do |event|
     sleep(2)
     event.user.add_role(532903286613999617)
     event.user.add_role(531508024691523595)
    bot.send_message(531494289008492545,"<@#{event.user.id}>　KnightComp 日本支部へようこそ！<#531496562434506762> と　<#532340815532392448> を読んでください！\nCheck the <#531496562434506762> and the <#532340815532392448> channel for information about KnightComp!")
end

bot.command :debug do |event|
    event.send_message()
end



bot.command :status do |event|

    start_typing("",event.channel.id)
    num = 0
    Get_Server_Status("122.210.136.164",27019)
    bot.send_file(event.channel.id, File.open('./tweet.png', 'r'))
    str = "#{@server.players} "
    while str.index("@id=") do

        str = str.slice(str.index("@id=")+4, str.length - str.index("@id=") - 4)
        num = num + 1

    end
    str2 = ""
    str = "#{@server.players} "
                m = str.scan(/@name="(.*?)"/)

                if num > 0 then
				str2 = "ログイン中のユーザー **#{num}/#{@hotserverdata[0]["maxplayer"]}**\n\n"
				for i in 1..num do

					if m[i-1][0] == "" then

						str2 = "#{str2}**[参加中のユーザー]**、"

					else

						str2 = "#{str2}**#{m[i-1][0]}**、"

					end
                end


        else
            str2 = "ログインしているユーザーはいません"
            end
        event.send_message(str2)

end

bot.command :ls do |event|

    key = event.text.split("\s")[1]
    puts key

    # if event.channel.id.to_i != 531621071292596225 then
    #     event.send_message("Botの操作は\#bot-spamでお願いします！")
    #     return
    # end
	start_typing("",event.channel.id)

    event.send_message "LogsTFから、「#{key}」を含む最新のマッチリザルトを検索します"
    start_typing("",event.channel.id)

#input = gets
APIKEY = ""
#MatchServerName = input.chomp!

STEMAIDOFFSET = 76561197960265728

Jsondata_serch_Matches = "http://logs.tf/api/v1/log?title=#{URI.encode key}"

uri = URI.parse(Jsondata_serch_Matches)
event.send_message "ログサーバーに問い合わせています・・・"
start_typing("",event.channel.id)
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
    return
end
#puts json_pars["logs"]


event.send_message "「#{key}」を含むマッチの検索結果：#{number}"
event.send_message "最新のマッチデータを取得 ID:#{matchID}\n===================="
matchdata = "http://logs.tf/json/#{matchID}"
start_typing("",event.channel.id)

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


event.send_message("#{title}\nmap:#{map}\ndate:#{date}\nLOG:https://logs.tf/#{matchID}")

rescue => exception
    event.send_message("この試合は完全な試合ではなかった可能性があります\nLOG:https://logs.tf/#{matchID}")
end

end
bot.command :log do |event|

	start_typing("",event.channel.id)

puts "名前からサーバーを検索して、最新のマッチリザルトを表示します"
#input = gets
APIKEY = "50A39519488BF3EC64B3463BEC71BCC0"
#MatchServerName = input.chomp!
MatchServerName = "[JP]フレンズサ"

STEMAIDOFFSET = 76561197960265728

Jsondata_serch_Matches = "http://logs.tf/api/v1/log?title=#{URI.encode MatchServerName}"

uri = URI.parse(Jsondata_serch_Matches)
puts "ログサーバーに問い合わせています・・・"
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
    puts "マッチが見つかりませんでした"
    exit
end
#puts json_pars["logs"]


puts "「hatena」を含むマッチの検索結果：#{number}件"
puts "最新のマッチデータを取得 ID:#{matchID}\n=============="
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
    puts "GET:#{imagedata}"
    open(imagedata, http_basic_authentication: ["", ""]) { |image|
        File.open("/home/daburutti/Test/#{key}.jpg","wb") do |file|
            file.puts image.read
        end
    }
    #-size 200x200 xc:none -fill walter.jpg -draw "circle 100,100 100,1" circle_thumb.png

    value = `convert -size 184x184 xc:none -fill \"/home/daburutti/Test/\[U\:1\:#{steamid[1]}\].jpg\" -draw \"circle 92,92 100,1\" \"/home/daburutti/Test/\[U\:1\:#{steamid[1]}\]_maru.png\"`
    puts "IMAGE CONVERTED"
}

puts data

puts "START IMAGE FAZE"

img = Magick::Image.new(1920,1080)
img = Magick::ImageList.new("/home/daburutti/Test/koredesuwa.png")
draw = Magick::Draw.new


draw.annotate(img, 0, 0, 100, -1897, score_red.to_s) do
    self.font      = '/home/daburutti/Test/ERASBD.TTF'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 270
    self.gravity   = Magick::CenterGravity
end

draw.annotate(img, 0, 0,-100, -1897, score_blu.to_s) do
    self.font      = '/home/daburutti/Test/ERASBD.TTF'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 270
    self.gravity   = Magick::CenterGravity
end


draw.annotate(img, 0, 0,810, 43, title.to_s) do
    self.font      = '/home/daburutti/Test/ERASBD.TTF'
    self.fill      = '#fcf9db'
    self.stroke    = 'transparent'
    self.pointsize = 65
    self.gravity   = Magick::NorthWestGravity
end

draw.annotate(img, 0, 0,125, 190, map.to_s) do
    self.font      = '/home/daburutti/Test/ERASDEMI.TTF'
    self.fill      = '#fcf9db'
    self.stroke    = 'transparent'
    self.pointsize = 70
    self.gravity   = Magick::NorthWestGravity
end

draw.annotate(img, 0, 0,970, 200, date.to_s) do
    self.font      = '/home/daburutti/Test/ERASDEMI.TTF'
    self.fill      = '#fcf9db'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::NorthWestGravity
end


string =  json_pars["names"][data["TOPKILL"][0]["name"].to_s] + "\n-" + data["TOPKILL"][0]["point"].to_s + "-"

draw.annotate(img, 0, 0, 0, -900, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 80
    self.gravity   = Magick::CenterGravity
end

string =  json_pars["names"][data["TOPKILL"][1]["name"].to_s] + "\n-" + data["TOPKILL"][1]["point"].to_s + "-"

draw.annotate(img, 0, 0, 610, -980, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end
string =  json_pars["names"][data["TOPKILL"][2]["name"].to_s] + "\n-" + data["TOPKILL"][2]["point"].to_s + "-"

draw.annotate(img, 0, 0, -610, -980, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end


string =  json_pars["names"][data["TOPASSIST"][0]["name"].to_s] + "\n-" + data["TOPASSIST"][0]["point"].to_s + "-"

draw.annotate(img, 0, 0, 0, 50, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 80
    self.gravity   = Magick::CenterGravity
end

string =  json_pars["names"][data["TOPASSIST"][1]["name"].to_s] + "\n-" + data["TOPASSIST"][1]["point"].to_s + "-"

draw.annotate(img, 0, 0, 610, -30, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end
string =  json_pars["names"][data["TOPASSIST"][2]["name"].to_s] + "\n-" + data["TOPASSIST"][2]["point"].to_s + "-"

draw.annotate(img, 0, 0, -610, -30, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end



string =  json_pars["names"][data["TOPDEATHS"][0]["name"].to_s] + "\n-" + data["TOPDEATHS"][0]["point"].to_s + "-"

draw.annotate(img, 0, 0, 0, 1010, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 80
    self.gravity   = Magick::CenterGravity
end

string =  json_pars["names"][data["TOPDEATHS"][1]["name"].to_s] + "\n-" + data["TOPDEATHS"][1]["point"].to_s + "-"

draw.annotate(img, 0, 0, 610, 930, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end
string =  json_pars["names"][data["TOPDEATHS"][2]["name"].to_s] + "\n-" + data["TOPDEATHS"][2]["point"].to_s + "-"

draw.annotate(img, 0, 0, -610, 930, string) do
    self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
    self.fill      = 'Black'
    self.stroke    = 'transparent'
    self.pointsize = 60
    self.gravity   = Magick::CenterGravity
end
puts data["MEDICS"][0]["team"].to_s
if  data["MEDICS"][0]["team"].to_s == "Blue" then
    puts "pt1"
    puts json_pars["names"][data["MEDICS"][1]["name"]].to_s
    puts json_pars["names"][data["MEDICS"][0]["name"]].to_s
    draw.annotate(img, 0, 0, -455, 1425, json_pars["names"][data["MEDICS"][0]["name"]].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'White'
        self.stroke    = 'transparent'
        self.pointsize = 90
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, 455, 1425, json_pars["names"][data["MEDICS"][1]["name"]].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'White'
        self.stroke    = 'transparent'
        self.pointsize = 90
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,1600, data["MEDICS"][0]["heal"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,1600, data["MEDICS"][1]["heal"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,1830, data["MEDICS"][0]["ubers"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,1830, data["MEDICS"][1]["ubers"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,2065, data["MEDICS"][0]["drops"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,2065, data["MEDICS"][1]["drops"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end

else
    puts "pt2"
    draw.annotate(img, 0, 0, -455, 1425, json_pars["names"][data["MEDICS"][1]["name"]].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'White'
        self.stroke    = 'transparent'
        self.pointsize = 90
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, 455, 1425, json_pars["names"][data["MEDICS"][0]["name"]].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'White'
        self.stroke    = 'transparent'
        self.pointsize = 90
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,1600, data["MEDICS"][1]["heal"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,1600, data["MEDICS"][0]["heal"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,1830, data["MEDICS"][1]["ubers"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,1830, data["MEDICS"][0]["ubers"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end

    draw.annotate(img, 0, 0, -475,2065, data["MEDICS"][1]["drops"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end
    draw.annotate(img, 0, 0, 475,2065, data["MEDICS"][0]["drops"].to_s) do
        self.font      = '/home/daburutti/Test/rounded-mplus-2c-heavy.ttf'
        self.fill      = 'Black'
        self.stroke    = 'transparent'
        self.pointsize = 100
        self.gravity   = Magick::CenterGravity
    end


end

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPKILL"][0]["name"]}_maru.png").first.resize(455, 455)

img.composite!(overlay, 745, 838, Magick::OverCompositeOp)
overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPKILL"][1]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 1405, 899, Magick::OverCompositeOp)

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPKILL"][2]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 185, 899, Magick::OverCompositeOp)


overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPASSIST"][0]["name"]}_maru.png").first.resize(455, 455)

img.composite!(overlay, 745, 1790, Magick::OverCompositeOp)
overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPASSIST"][1]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 1405, 1851, Magick::OverCompositeOp)

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPASSIST"][2]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 185,1851, Magick::OverCompositeOp)

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPDEATHS"][0]["name"]}_maru.png").first.resize(455, 455)

img.composite!(overlay, 745, 2750, Magick::OverCompositeOp)

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPDEATHS"][1]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 1405, 2813, Magick::OverCompositeOp)

overlay = Magick::Image.read("/home/daburutti/Test/#{data["TOPDEATHS"][2]["name"]}_maru.png").first.resize(330, 330)

img.composite!(overlay, 185, 2813, Magick::OverCompositeOp)
#img.display
#img.display
ins = Time.new.sec
img.write("/var/www/html/tf2/discordbot_img/#{matchID}-#{ins}.png")

bot.send_file(event.channel.id, File.open('/var/www/html/tf2/discordbot_img/#{matchID}-#{ins}.png', 'r'))
event.send_message("LOG:https://logs.tf/#{matchID}")

rescue => exception
    event.send_message("この試合は完全な試合ではなかった可能性があります\nLOG:https://logs.tf/#{matchID}")
end
end
bot.run
