require 'open-uri'
require 'net/http'
require 'json'
require 'uri'

class Nfl < PluginBase 
	include Cinch::Plugin

	$help_messages << "!nfl gamelist   show every game this week"
	$help_messages << "!nfl current    show scores for games this week"
	$help_messages << "!nfl <team abbr> game    show game time for games with teams that match <team abbr>"
	$help_messages << "!nfl <team abbr> score    show game score for games with team that match <team abbr>"

	@nfl = nil
  listen_to :channel 
  listen_to :private

	def initialize(*args)
		super
	end
	
	def react_to_message(m)
	  if active?(m,"nfl")
      unless @nfl
        @nfl = true
        begin
          case m.message
          when /^!help nfl$/
            help(m, "!nfl")
          when /^!nfl current$/
            list_active_games(m)
          when /^!nfl gamelist$/
            list_weeks_games(m)
          when /^!nfl$/
            help(m, "!nfl")
          when /!nfl (\S+) score$/
            list_active_games(m,$1)
          when /!nfl (\S+) game$/
            list_weeks_games(m,$1)
          end	
            
        rescue Exception => e
          error(m,e)
        end
        @nfl = nil
      end
    end
	end
	
	def list_active_games(m, team = ".")
		begin
			@active = JSON.parse open("http://www.nfl.com/liveupdate/scores/scores.json").read
      result = ""
			@active.each do |game|
				home = game[1]["home"]["abbr"]
				away = game[1]["away"]["abbr"]
				hscore = game[1]["home"]["score"]["T"]
				ascore = game[1]["away"]["score"]["T"]
				qtr = game[1]["qtr"]
				if(home.match(/#{team}/i) or away.match(/#{team}/i))
					result =  "#{result}#{home} (#{hscore}) vs #{away} (#{ascore}) #{qtr if qtr == "Final"}\n"
				end
			end
			reply(m,result) unless result.empty?
		rescue Exception => e
			error(m,e)
		end
	end
	
	def list_weeks_games(m, team = ".")
		begin
			@week = JSON.parse open("http://www.nfl.com/liveupdate/scorestrip/ss.json").read
			result = ""
			result =  "Week #{@week["w"]} Games:\n" if team == "."
			@week["gms"].each do |game|
				day = game["d"]
				h = game["h"]
				v = game["v"]
				hnn = game["hnn"]
				vnn = game["vnn"]
				time = game["t"]
				time.match /(\d+):(\d+)/
				time = $1.to_i - 1
				time += 12 if time == 0
				time = "#{time}:#{$2}"
				
				
				if(h.match(/#{team}/i) or v.match(/#{team}/i))
					result = "#{result}#{h} #{hnn} vs #{v} #{vnn} (#{day}: #{time})\n"
				end
			end
			reply(m, result) unless result.empty?
		rescue Exception => e
			error(m,e)
		end
	end
end
