class Summon < PluginBase
  include Cinch::Plugin

	$help_messages << ["summon","!summon <number>    Master summon's <number> minions (default 1)."]

	listen_to :channel
	listen_to :private
	
	def react_to_message(m)
	  if active?(m,"summon")
			begin
				case m.message
        when /^!summon$/
          summon(m,1,m.channel)
        when /^!summon(\s+(\d+))?((\s+in)?\s+(\S+))?$/
          summon(m,$2,$5)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def summon(m,number,channel)
	  number = number ? number.to_i : 1
	  channel = channel ? channel : m.channel
	  if m.user == User($master) && channel
	    $settings["settings"]["channel"].each do |c|
        @channel = c if c.match(/^#{Regexp.escape(channel)}/)
      end
      number.times do
        system("ruby minion.rb '#{@channel}' &")
      end
    end
	end
end
