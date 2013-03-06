require 'open-uri'
require 'net/http'
require 'json'
require 'uri'
#allow changing message text
module Cinch
  class Message
    def message= text
      @message = text
    end
  end
end

class PluginBase
	include Cinch::Plugin

	listen_to :channel
	listen_to :private

  @@channel_plugins = nil
  @prefix = ""
  @private = false
  @memory ||= {}
	def initialize(*args)
    super
    @memory ||= {}
    unless @@channel_plugins
      @@channel_plugins = {}
      $settings["settings"]["channel"].each do |channel|
        $settings["settings"]["plugins"].each do |plugin|
          channel_name = channel.split(/\s+/).first
          if @@channel_plugins[channel_name]
            @@channel_plugins[channel_name][plugin] = true
          else
            @@channel_plugins[channel_name] = {plugin => true}
          end
        end
      end
      if $settings["settings"]["deactivate"]
        $settings["settings"]["deactivate"].each do |channel, plugins|
          plugins.each do |plugin|
            @@channel_plugins[channel][plugin] = false
          end
        end
      end
    end
  end

  def react_to_message(m)
    case m.message
    when /^!activate (.+)$/
      set_active(m, $1, true)
    when /^!deactivate (.+)$/
      set_active(m, $1, false)
    when /^!activate$/
      set_all(m,true)
    when /^!deactivate$/
      set_all(m,false)
    else
      if m.user and m.user.nick == $master and not @prefix.empty?
        reply(m, m.message) unless m.message.match /^\!/
      end
    end
  end

  def get_clone(m)
    m2 = m.clone
    m2.message = m.message.clone
    m2
  end

	def listen(m)
	  begin
      m = get_clone(m)
      if m.message.match /^!give\s+(\S+)\s+(.*)$/
        @prefix = "#{$1}: "
        @private = false
        m.message = $2
      elsif m.message.match /^!send\s+(\S+)\s+(.*)$/
        @prefix = "#{$1}: "
        @private = true
        m.message = $2
      else
        @private = false
        @prefix = ""
      end
      react_to_message(m)
    rescue Exception => e
      error(m,e)
    end
	end

	def validate_recipient(m, recipient)
    channels = $settings['settings']['channel'].map{|channel| channel.split(/\s+/).first}
    channels = channels.select{|c| Channel(c).users.map{|u| u.first.nick}.include? m.user.nick}
    users = []
    channels.each do |channel|                                              
      users << Channel(channel).users.map{|user| user.first.nick}
    end
    users.flatten!
    choices = channels + users.uniq

    unless choices.include?(recipient)
      best_guess = choices.sort_by{|option| closest_match(recipient,option)}.first
      m.reply "Could not find #{recipient}. Did you mean #{best_guess}?"
      return false
    end
    return true
  end

	def reply(m,message)
	  unless @prefix.empty?
	    if validate_recipient(m,@prefix[0..-3])
        if $settings['settings']['channel'].include? @prefix[0..-3]
          Channel(@prefix[0..-3]).send message.gsub(/^\S+:\s/,"")
        elsif @private
          User(@prefix[0..-3]).send message.gsub(/^\S+:\s/,"")
        elsif m.channel
          message = message.gsub(/^\S+:\s/,"")
          m.reply(@prefix + message )
        else
          message = message.gsub(/^\S+:\s/,"")
          broadcast(m,@prefix[0..-3],message)
        end
      end
    else
      m.reply(message)
    end
  end

	def broadcast(m,user,message)
	  if validate_recipient(m, user)
      $settings['settings']['channel'].map{|channel|channel.split(/\s+/).first}.each do |c|
        users = Channel(c).users.collect{|u| u.first.nick}
        if users.include? m.user.nick and users.include? user
          Channel(c).send "#{user}: #{message}"
        end
      end
    end
	end


  def pm(user,message, send_to_prefix = true)
    if send_to_prefix and not @prefix.empty?
      User(@prefix[0..-3]).send message
    else
      user.send(@prefix + message)
    end
  end

	def closest_match(attempt,actual)
    key = [attempt,actual].join(',')
    return @memory[key] if @memory[key]
    return attempt.length if actual.length == 0
    return actual.length if attempt.length == 0

    cost = (actual[0] == attempt[0]) ? 0 : 1
    distance = [closest_match(attempt[1..-1],actual) + 1,
                closest_match(attempt,actual[1..-1]) + 1,
                closest_match(attempt[1..-1], actual[1..-1]) + cost].min

    @memory[key] = distance
    return distance
  end

	def set_active(m,plugin,value)
	  if m.channel
      if m.user.nick == $master
        channel_name = m.channel.name.split(/\s+/).first
        if @@channel_plugins[channel_name][plugin] != nil
          @@channel_plugins[channel_name][plugin] = value
          m.reply "#{plugin} #{"de" unless value}activated."
        else
          best_guess = $settings["settings"]["plugins"].sort_by{|option| closest_match(plugin,option)}.first
          m.reply "#{plugin} not available. Did you mean #{best_guess}?"
        end
      end
    else
      m.reply "Please do that in a channel."
    end
  end

  def set_all(m,value)
    if m.channel
      changes = []
      if m.user.nick == $master
        channel_name = m.channel.name.split(/\s+/).first
        @@channel_plugins[channel_name].each do |key,val|
          unless key.match "plugin_base"
            if @@channel_plugins[channel_name][key] != value
              @@channel_plugins[channel_name][key] = value
              changes << key
            end
          end
        end
      end
      if changes.any?
        reply(m,"#{"de" unless value}activating #{changes.join(", ")}") 
      end
    else
      m.reply "Please do that in a channel"
    end
  end

  def active?(m,plugin)
    if m.channel
      channel_name = m.channel.name.split(/\s+/).first
      if @@channel_plugins[channel_name][plugin] != nil
        return @@channel_plugins[channel_name][plugin]
      else
        best_guess = $settings["settings"]["plugins"].sort_by{|option| closest_match(plugin,option)}.first
        User($master).send "Incorrectly asked for availabilty of #{plugin}. Did you mean #{best_guess}?"
      end
    else
      return true
    end
  end

	def help(m,prefix)
		$help_messages.each {|help| pm(m.user,help) if help.start_with?(prefix)}
	end
	
	def error(m,e)
		User($master).send "Be vigilant! (#{e.message})\n#{e.backtrace.join("\n")}"
	end
end
