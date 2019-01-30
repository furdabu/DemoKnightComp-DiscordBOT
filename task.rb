require 'discordrb'
require 'steam-condenser'


@bot = Discordrb::Commands::CommandBot.new token: '', client_id: , prefix: '!'

begin
    @server = SourceServer.new("122.210.136.164", 27019)
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
     @bot.send_message(531643454846009344,"<@&532903286613999617> サーバー内から呼びかけられました！:プレイヤー募集中！\n現在のサーバーステータス\n MAP : #{mapname} Online : #{players[1]}/#{maxplayer[1]}\n**Quick join link** : **steam://connect/www.dabudabu.net:27019/furematch**")

    rescue => exception
        @bot.send_message(531643454846009344,"<@&532903286613999617> TF2サーバー内から呼びかけれました：プレイヤーを募集しています！")
    end
