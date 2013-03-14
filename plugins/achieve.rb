#Credit for this plugin goes to mikeweber
class Achieve < PluginBase
  include Cinch::Plugin

	$help_messages << ["acheive","!achieve <number> <message>   Generate an achievement worth <number> points"]

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"achieve")
			begin
				case m.message
        when /^!achieve((ment)? unlocked)?\s+(\d*)\s*(.*)$/
          achieve(m,$3,$4)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def achieve(m,points,msg)
    points = points.empty? ? 5 : points
    msg.strip!
    email = "achieveinatoring@mailinator.com"
    uri = URI.parse("http://www.justachieveit.com/jai/code.jsp")
    response = Net::HTTP.post_form(uri,{:type => 1, :email => email, :text => msg, :score => points})
    
    reply_string = if response.is_a?(Net::HTTPRedirection) && response['location']
      badge_response = Net::HTTP.get_response(URI.parse(response['location']))
      if badge_response.is_a?(Net::HTTPOK) && matches = badge_response.body.match(/src="(http:\/\/cdn\.justachieveit\.com\/[^"]+)"/)
        tiny = open("http://tinyurl.com/api-create.php?url=#{URI.escape($1)}").read
        if tiny != "Error"
          tiny
        else
          "Sorry, I couldn't find the badge's URL"
        end
      else
        "Sorry, I couldn't find the badge's URL"
      end
    else
      "Sorry, I couldn't figure out where to get the badges URL"
    end
    reply(m,"#{m.user.nick}: #{reply_string}")
	end
end
