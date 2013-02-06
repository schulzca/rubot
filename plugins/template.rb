class template < PluginBase
  include Cinch::Plugin

	$help_messages << "!template   this is what this plugin does"

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"template")
			begin
				case m.message
				when /^!help template$/
					help(m, "!template")
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def template_method(m)
	  #JSON EXAMPLE
		#	url = ""
		#	json = JSON.parse open(url).read
	end
end
