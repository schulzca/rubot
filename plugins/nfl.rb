require 'open-uri'
require 'net/http'
require 'json'
require 'uri'

class Nfl 
	include Cinch::Plugin

	$help_messages << "!nfl gamelist   show every game this week"
	$help_messages << "!nfl current    show scores for games this week"

	listen_to :channel
	
	def initialize(*args)
		super
	end
	
	def listen(m)
		begin
			case m.message
			when /^!nfl help$/
				help(m)
			when /^!nfl current$/
				list_active_games(m)
			when /^!nfl gamelist$/
				list_weeks_games(m)
			when /^!nfl$/
				help(m)
			end	
				
		rescue Exception => e
			error(m,e)
		end
	end

	def help(m)
		$help_messages.each {|help| m.reply(help) if help.start_with?("!nfl")}
	end
	
	def list_active_games(m)
		begin
			@active = JSON.parse open("http://www.nfl.com/liveupdate/scores/scores.json").read
			@active.each do |game|
				home = game[1]["home"]["abbr"]
				away = game[1]["away"]["abbr"]
				hscore = game[1]["home"]["score"]["T"]
				ascore = game[1]["away"]["score"]["T"]
				qtr = game[1]["qtr"]
				
				m.reply "#{home} (#{hscore}) vs #{away} (#{ascore}) #{qtr if qtr == "Final"}"
				#str << " FINAL" if game["qtr"] == "Final"
			end
		rescue Exception => e
			error(m,e)
		end
	end
	
	def list_weeks_games(m)
		begin
			@week = JSON.parse open("http://www.nfl.com/liveupdate/scorestrip/ss.json").read
			m.reply "Week #{@week["w"]} Games:"
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
				
				
				
				m.reply "#{h} #{hnn} vs #{v} #{vnn} (#{day}: #{time})"
				#str << " FINAL" if game["qtr"] == "Final"
			end
		rescue Exception => e
			error(m,e)
		end
	end
	
	def error(m, e)
		m.reply "I told you to expect bad things. (#{e.message})"
	end
	
end
