require 'discordrb'
require "date"

DISCORD_TOKEN = '..-'
CLIENT_ID =
CHANNEL_ID = 531643454846009344
CHANNEL_ID_DEBUG = 532940099412033537
USER_ID = 531657432544313345

@bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, client_id: CLIENT_ID, prefix: '!'



h = 0
m = 0
sleep(5)
ltid = 0
file = File.open("/home/daburutti/DKC_bot/time")
file.each do |a|
 ltid = a.to_i
end

if ltid == 0 then
    puts "closed"
    return
end

nowTime = DateTime.now

case ltid
when 1 then
    h = 21
    m = 0
when 2 then
    h = 21
    m = 30
when 3 then
    h = 22
    m = 00
end

now_h = nowTime.hour
now_m = nowTime.minute

puts ltid
puts h
puts m


if h == now_h && m == now_m then
    @bot.send_message(CHANNEL_ID,"<@&532903286613999617> 全員集合！| Everyone gather!!")
else
    return
end


