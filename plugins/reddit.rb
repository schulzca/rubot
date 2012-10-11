class Reddit
	include Cinch::Plugin

	$help_messages << "!reddit    grab a link from reddit! options: r/<sub>, <post number>, img|image|imgur"

	listen_to :channel
	
	def listen(m)
		begin
			case m.message
			when /^!r(ed(dit)?)? help$/
				help(m)
			when /^!r(ed(dit)?)?/
				get_link(m)
			end
				
		rescue Exception => e
			error(m,e)
		end
	end
	
	def get_link(m)
		count = m.message.match(/\b(\d+)\b/) ? "count=#{$1 - 1}" : "count=0"
		limit = !m.message.match(/img|image|imgur/)
		sub   = m.message.match(/r\/(\S+)/) ? "r/#{$1}/" : ""
		if limit
			json = JSON.parse open("http://www.reddit.com/#{sub}.json?#{count}&limit=1").read
			data = json["data"]["children"][0]	
			m.reply "#{data["title"]}#{data["over_18"] ? " (NSFW)" : ""} | #{data["url"]}"
		else
			json = JSON.parse open("http://www.reddit.com/#{sub}.json?#{count}&limit=100").read
			data = json["data"]["children"].each do |post|
				if(post["domain"].match(/imgur/))
					m.reply "#{data["title"]}#{data["over_18"] ? " (NSFW)" : ""} | #{data["url"]}"
					break
				end
			end
		end
	end
	
	def help(m)
		$help_messages.each {|help| m.reply(help) if help.start_with?("!reddit")}
	end
	
	def error(m,e)
		user = (m.channel.users.select{|u| u.nick == "schulzca"}).first
		if(user)
			user.send "Be vigilant! (#{e.message})"
		else
			m.user.send "I had a problem responding to '#{m.message}', please notify schulzca when he returns."
		end
	end
end
