require 'discordrb'

DISCORD_TOKEN = ''
CLIENT_ID =

CHANNEL_ID = 531643454846009344
MESSAGE_ID = 534548024219926528

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
    start_typing(DISCORD_TOKEN,cn.id)
    sleep(1)

    if key.id == MESSAGE_ID then

        puts "main message detected"
        next

    end

    cn.delete_message(key)
    puts "deleted message, id => #{key.id}"

end

puts "DONE"

@bot.send_message(CHANNEL_ID,"<@&532903286613999617> 今夜、ナイトコンプを行いますか？　投票しましょう！\nDo you wanna play pugs tonight? vote now!")
sleep(1)


history = cn.history(1)

history[0].create_reaction(":ok::538307999777685524")
sleep(1)
history[0].create_reaction(":hmm::538308026449526784")
sleep(1)
history[0].create_reaction(":ng::538308044543623198")