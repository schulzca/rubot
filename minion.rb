require 'rubygems'
require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'

def random_name
  constants = %w(b c d f g h j k l m n p qu r s t v w x y z ch st tr pl)
  vowels = %w(a e i o u y ie au ea)
  name = ""
  5.times do |i|
    name += (i % 2 == 0 ? constants.shuffle.first : vowels.shuffle.first)
  end
  name
end

begin
  nick = random_name
  $settings = YAML.load(File.read("minion.yml"))
  $settings["settings"]["channel"] = [ARGV.first]
  $settings["settings"]["nick"] = nick
end

$master = $settings["settings"]["master"]

# This method is taken from rails core
# (didn't want to load the entire lib for one method)
# http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-constantize
def constantize(camel_cased_word)
  names = camel_cased_word.split('::')
  names.shift if names.empty? || names.first.empty?

  constant = Object
  names.each do |name|
    constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
  end
  constant
end

$help_messages = []

if $settings["settings"]["abilities"]
  $settings["settings"]["abilities"].each do |plugin|
    require "./abilities/#{plugin}"
  end
end

$irc  = Cinch::Bot.new do
  
  configure do |c|
    c.server = "irc.freenode.com"
    c.nick = $settings["settings"]["nick"]
    c.channels = $settings["settings"]["channel"]
    c.plugins.plugins = $settings["settings"]["plugins"].map {|plugin| constantize(plugin.split("_").map {|word| word.capitalize}.join(""))} if $settings["settings"]["plugins"]
  end

  on :message, /^!help$/ do |m|
    topics = $help_messages.map{|message| message.split(/\s+/)[0].gsub(/[!:]/,"") }.uniq
    m.user.send "Available topics: #{topics.join(", ")}\nLearn more with '!help <topic>'"
  end

  on :message, /^!unsummon( #{$settings["settings"]["nick"]})?$/ do |m|
    if m.user == User($master)
      $irc.quit
      system("exit")
    end
  end
end

$irc.start
