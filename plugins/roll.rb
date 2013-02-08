class Roll < PluginBase
  include Cinch::Plugin

	$help_messages << "!roll   Roll dice.  Format: 4d6, 2*d12, 2d2d10 (Default 1d6). [-steps] to see each roll."

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"roll")
			begin
				case m.message
				when /^!help roll$/
					help(m, "!roll")
        when /^!roll\s*$/
          roll(m,"d6")
        when /^!roll\s+([0-9d*\s]*\s*(-s(teps)?)?)\s*$/ 
          roll(m,$1)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end

	def roll(m,exp)
	  @total = 0
	  @steps = exp.match /-s(teps)?/
	  @rolls = []
	  @dice = ""
	  exp = exp.gsub(/-s(teps)?/,"") if @steps
    exp = exp.gsub(/\s/,"")
    exp = exp.gsub(/(\*+)/,"*")
    exp = exp.gsub(/(d+)/,"d")
    #Evaluate all rolls with variable roll numbers
    while exp.match /(\d+)?d\d+d/
      exp = exp.gsub /(\d+)?d(\d+)d/ do 
        total = 0
        @dice = $2.to_i
        number = $1 ? $1.to_i : 1
        number.times do
          val = rand(@dice) + 1
          @rolls << val
          total += val
        end
        reply(m,"#{@rolls.size} roll(s) of the d#{@dice} resulted in: #{@rolls.join(", ")}") if @steps
        @rolls = []
        "#{total}d"
      end
      reply(m,"Results so far: #{exp}") if @steps
    end
    #Separate remaining rolls and multipliers
    exp = exp.split("*")
    #Evaluate remaining rolls
    @rolls = []
    exp.map! do |val| 
      if val.match /(\d+)?d(\d+)/
        total = 0
        @dice = $2.to_i
        number = $1 ? $1.to_i : 1
        number.times do
          val = rand(@dice) + 1
          @rolls << val
          total += val
        end
        reply(m,"#{@rolls.size} roll(s) of the d#{@dice} resulted in: #{@rolls.join(", ")}") if @steps
        @rolls = []
        total
      else
        val.to_i
      end
    end
    reply(m,"Results so far: #{exp.join("*")}") if @steps
    #Find total
    total = 1
    exp.each do |val|
      total *= val
    end
    reply(m,"#{m.user.nick} rolled a #{total}")
  end
end
