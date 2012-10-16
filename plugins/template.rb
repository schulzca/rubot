class template < PluginBase
  include Cinch::Plugin

	$help_messages << "!template   this is what this plugin does"

	
	def listen(m)
			begin
				case m.message
				when /^!template help$/
					help(m, "!template")
  			end
			rescue Exception => e
				error(m,e)
			end
	end
	
	def template_method(m)
	  #JSON EXAMPLE
		#	url = ""
		#	json = JSON.parse open(url).read
	end
end
