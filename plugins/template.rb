class Template < PluginBase
  include Cinch::Plugin

	$help_messages << ["template","!template   this is how to use this plugin"]

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"template")
      case m.message
      when /^!template$/

      end
    end
	end
	
	def template_method(m)
	  #JSON EXAMPLE
		#	url = ""
		#	json = JSON.parse open(url).read
	end
end
