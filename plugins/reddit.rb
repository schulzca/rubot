class Reddit
	include Cinch::Plugin

	$help_messages << "!reddit    grab a link from reddit! options: r/<sub>, <post number>, img|image|imgur"

	listen_to :channel
	@reddit = nil
	
	def listen(m)
		unless @reddit
			@reddit = true
			begin
				case m.message
				when /^!r(ed(dit)?)? help$/
					help(m)
				when /^!r(ed(dit)?)?\b/
					get_link(m)
				when /#{$settings['settings']['nick']}/
					get_link(m) if m.message.match(/\br(ed(dit)?)?\b/)
				end
					
			rescue Exception => e
				error(m,e)
			end
			@reddit = nil
		end
	end
	
	def get_link(m)
		count = m.message.match(/\b(\d+)\b/) ? $1.to_i - 1 : 0
		limit = !m.message.match(/img|image|imgur/)
		sub   = m.message.match(/r\/(\S+)/) ? "r/#{$1}/" : ""
		count = count < 0 ? 0 : count
		if count > 100
			m.reply "I can only search up to post 100"
		end
		count = count > 99 ? 99 : count
		if limit
			url = "http://www.reddit.com/#{sub}.json?limit=100"
			json = JSON.parse open(url).read
			data = json["data"]["children"][count]["data"]	
			m.reply "#{data["over_18"] ? "(NSFW) " : ""}#{data["title"]} | #{data["url"]}"
		else
			json = JSON.parse open("http://www.reddit.com/#{sub}.json?#{count}&limit=100").read
			post_number = 0
			json["data"]["children"].each do |post|
				data = post["data"]
				if(post["data"]["domain"].match(/imgur/) && post_number >= count)
					m.reply "#{post["data"]["title"]}#{post["data"]["over_18"] ? " (NSFW)" : ""} | #{post["data"]["url"]}"
					break
				end
				post_number += 1
			end
		end
	end
	
	def help(m)
		$help_messages.each {|help| m.reply(help) if help.start_with?("!reddit")}
	end
	
	def error(m,e)
		User("schulzca").send "Be vigilant! (#{e.message})"
	end
end
