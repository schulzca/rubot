class Rhyme < PluginBase 
	include Cinch::Plugin
	listen_to :channel
	listen_to :private

	$help_messages << ["rhyme","!rhyme <word>  find rhymes for <word>"]

	@rhyme = nil
	def initialize(*args)
		super
	end
	
	def react_to_message(m)
	  if active?(m,"rhyme")
      unless @rhyme
        @rhyme = true
        case m.message
        when /^!rhyme help$/
          help(m, "!rhyme")
        when /^!rhyme (\S+)$/
          get_rhymes(m,$1)
        when /^!rhyme$/
          help(m, "!rhyme")
        end	
        @rhyme = nil
      end
    end
	end

	def get_rhymes(m, word)
		begin
			@words = JSON.parse open("http://rhymebrain.com/talk?function=getRhymes&word=#{word}").read
      word_array = []
			@words.each do |word_info|
				word_array << word_info["word"] if word_info["score"] == 300
			end
			reply(m,"#{m.user.nick}: Words that rhyme with #{word}: #{word_array.join(", ")}") unless word_array.empty?
		rescue Exception => e
			error(m,e)
		end
	end
end
