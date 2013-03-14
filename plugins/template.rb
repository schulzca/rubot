class template < PluginBase
  include Cinch::Plugin

	$help_messages << ["template","!template   this is how to use this plugin"]

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"template")
			begin
				case m.message
        when /^!template$/

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
