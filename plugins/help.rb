class Help < PluginBase
  include Cinch::Plugin

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"help")
      case m.message
      when /^!help$/
        display_help_options(m)
      when /^!help\s+(.+)/
        display_help_for(m,$1)
      end
    end
	end
	
	def display_help_options(m)
    topics = $help_messages.map{|message| message[0]}.uniq
    pm(m.user, "Available topics: #{topics.join(", ")}\nLearn more with '!help <topic>'")
	end

	def display_help_for(m,topic)
    topic.strip!
    choices = $help_messages.map{|message| message[0]}.uniq
    if choices.include? topic
      $help_messages.each do |message|
        reply(m, message[1]) if message[0] == topic  
      end
    else
      best_guess = choices.sort_by{|option| closest_match(topic,option)}.first
      reply(m, "Could not find a '#{topic}' topic. Did you mean #{best_guess}?")
    end
  end
end
