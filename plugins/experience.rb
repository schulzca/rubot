class Experience < PluginBase
	include Cinch::Plugin

  $help_messages << "!exp   !smack <nick> when they deserve it."
  $help_messages << "!exp   !props <nick> when they did something awesome."
	$help_messages << "!exp   !level <nick>? to see a persons level"
	$help_messages << "!exp   !levels to see everyone's level"

	listen_to :channel
	listen_to :private

	@json = nil
  GOOD_MESSAGES = ["<nick> wins one internet. +<points> experience.",
                   "You have my sword. And my axe! +<points> experience for <nick>",
                   "All your base are belong to <nick>. +<points> experience.",
                   "<nick> is lengend... wait for it... dary! +<points> experience.",
                   "<nick> is a leaf on the wind. Watch how he soars. +<points> experience."]
  BAD_MESSAGES = ["<nick> lost the game. -<points> experience.",
                  "You shall not pass! -<points> experience for <nick>",
                  "It's a trap! -<points> for <nick>",
                  "<nick> is a scruffy-looking nerfherder! -<points> experience"]

  def initialize(*args)
    super
    @json = JSON.parse open($settings["settings"]["level_path"]).read
  end

	def listen(m)
	  unless m.channel.to_s.match /wdmgroup/
			begin
				case m.message
				when /^!exp(erience)?( help)?$/
					help(m, "!exp")
				when /^!level$/
				  send_level(m, m.user.nick)
				when /^!level (\S+)$/
				  send_level(m,$1)
				when /^!levels$/
				  send_all_levels(m)
			  when /^!props (\S+)$/
			    give_props(m,$1)
			  when /^!smack (\S+)$/
			    smack(m,$1)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end

  def userlist(m)
    m.channel.users.collect{|u| u.first.nick}
  end

	def give_props(m,nick)
    if userlist(m).include? nick
      if(m.user.nick == nick)
        score = @json[m.channel][nick]["exp"]
        if score < 50
          m.reply "#{nick} loses #{score} exp for boasting."
        else
          m.reply "#{nick} loses 50 exp for boasting."
          score = 50
        end
        @json[m.channel][nick]["exp"] = score
        save_json
      else
        give_points(m,nick,5)
      end
    else
      m.reply "That user is not here."
    end
  end

	def smack(m,nick)
    if userlist(m).include? nick
      if(m.user.nick == nick)
        score = @json[m.channel][nick]["exp"]
        m.reply "#{nick} has Tyler Durden thing going on. 5 exp lost."
        score -= 5
        @json[m.channel][nick]["exp"] = score
        save_json
      else
        lose_points(m,nick,5)
      end
    else
      m.reply "That user is not here."
    end
  end

  def random_good_reply(nick,amt)
    GOOD_MESSAGES.sample.gsub("<nick>", nick).gsub("<points>",amt.to_s)
  end

  def random_bad_reply(nick,amt)
    BAD_MESSAGES.sample.gsub("<nick>", nick).gsub("<points>",amt.to_s) 
  end

  def give_points(m,nick,amt)
    user = get_nick_data(m, nick)
    level = user["level"]
    exp = user["exp"]
    m.reply random_good_reply(nick, amt)
    exp += amt
    if exp >= level * 10
      exp -= level * 10
      level += 1
      m.reply "#{nick} leveled up to level #{level}!"
    end
    @json[m.channel][nick]["level"] = level
    @json[m.channel][nick]["exp"] = exp
    save_json
  end

  def lose_points(m,nick,amt)
    user = get_nick_data(m, nick)
    exp = user["exp"]
    m.reply random_bad_reply(nick,amt)
    exp -= amt
    @json[m.channel][nick]["exp"] = exp
    save_json
  end

  def save_json
    unless $writing_to_file
      $writing_to_file = true
      File.open($settings["settings"]["level_path"], 'w'){|f|f.write(@json.to_json)}
      $writing_to_file = false
    end
  end

	def send_all_levels(m)
    if m.channel
      response = []
      m.channel.users.each do |user|
        user = user.first.nick
        if(data = get_nick_data(m,user))
           response << "#{user}: Lvl: #{data['level']} Exp: #{data['exp']}"
        end
      end
      m.user.send(response.join("\n")) unless response.empty?
      save_json
    else
      m.reply "Please do that in the channel."
    end
  end

	def send_level(m, nick)
	  if nick_data = get_nick_data(m,nick)
      m.reply "#{nick}: Lvl: #{nick_data['level']} Exp: #{nick_data['exp']}"
      save_json
    end
  end

  def get_nick_data(m, user)
    if m.channel
      if chan = @json[m.channel]
        if nick = chan[user]
          return nick
        elsif userlist(m).include? user
          @json[m.channel][user] = {"level" => 1, "exp" => 0}
          return @json[m.channel][user] 
        else 
          m.reply "That person isn't here."
          return nil
        end
      else
        @json[m.channel] = {user => {"level" => 1, "exp" => 0}}
        return @json[m.channel][user]
      end
    else
      m.reply "Please do that in the channel."
      return nil
    end
  end
	
	def template_method(m)
	  #JSON EXAMPLE
		#	url = ""
		#	json = JSON.parse open(url).read
	end
end
