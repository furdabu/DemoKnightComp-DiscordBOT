require 'discordrb'

DISCORD_TOKEN = '..-'
CLIENT_ID =
CHANNEL_ID = 531643454846009344
CHANNEL_ID_DEBUG = 532940099412033537
USER_ID = 531657432544313345

ok = 0
hmm = 0
ng = 0
total = 0

time = "00:00"
timecode = 0

@bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, client_id: CLIENT_ID, prefix: '!'


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

cn = @bot.channel(CHANNEL_ID)

last_ten_messages = cn.history(100)
last_ten_messages.each do | key |
    #start_typing(DISCORD_TOKEN,cn.id)
    sleep(1)

    if key.user.id == USER_ID then

        begin
            ok = key.reactions["ok"].count - 1
            hmm = key.reactions["hmm"].count - 1
            ng = key.reactions["ng"].count - 1

            total = ok + hmm + ng

            puts total
             next

        rescue => e

        end

    end

end

if (total <= 0) then
    @bot.send_message(CHANNEL_ID,"<@&532903286613999617> 自動招集に必要な票数に達していません、もしくは処理中に何らかのエラーが発生しました。")
    timecode = 0
    return
end

puts "ok:#{ok}"
puts "ng:#{ng}"
puts "hmm:#{hmm}"


total = ok + hmm + ng
ok = ok * 1
hmm = hmm * 0.85
ng = ng * -1

caled = (ok + ng + hmm) / (total * 1)

puts "評価値:#{caled}"

if total >= 8 && caled >= 0.7 then

    time = "21:00"
    timecode = 1

elsif caled >= 0.55 then

    time = "21:30"
    timecode = 2
else

    time = "22:00"
    timecode = 3
end

@bot.send_message(CHANNEL_ID,"<@&532903286613999617> 今夜、pugを開催します時間は **#{time}** (GMT+9)からです！\nWe will be holding a pug tonight at **#{time}** (GMT+9) come play!")

File.open("/home/daburutti/DKC_bot/time","w") do | b |
    b.print(timecode)
end


