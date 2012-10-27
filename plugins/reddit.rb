class Reddit < PluginBase
  include Cinch::Plugin
	listen_to :channel
	listen_to :private

	$help_messages << "!reddit    grab a link from reddit! options: r/<sub>, <post number>, img|image|imgur"

	@reddit = nil
	
	def listen(m)
		unless @reddit
			@reddit = true
			begin
				case m.message
				when /^!r(ed(dit)?)? help$/
					help(m, "!reddit")
				when /^!r(ed(dit)?)?\b/
					get_link(m)
				when /#{$settings['settings']['nick']}/
					get_link(m) if m.message.match(/\br(ed(dit)?)?\b/)
				end
					
			rescue Exception => e
			  if e.message.length < 256
          error(m,e)
        else
          m.reply "No results."
        end
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
			unless json['error'] == 403
        data = json["data"]["children"][count]["data"]	
        m.reply "#{data["over_18"] ? "(NSFW) " : ""}#{data["title"]} | #{data["url"]}"
      else
        m.replty "No results."
      end
		else
			json = JSON.parse open("http://www.reddit.com/#{sub}.json?limit=100").read
			unless json['error'] == 403
        post_number = 0
        json["data"]["children"].each do |post|
          data = post["data"]
          if(data["domain"].match(/imgur/) && post_number >= count)
            m.reply "#{data["title"]}#{data["over_18"] ? " (NSFW)" : ""} | #{data["url"]}"
            break
          end
          post_number += 1
        end
      else
        m.reply "No results."
      end
		end
	end
end
