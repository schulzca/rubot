require 'rubygems'
require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'
require 'mechanize'

def random_name
  agent = Mechanize.new
  page = agent.get('http://www.rinkworks.com/namegen/')
  form = page.forms[1]
  form.c = "<<s|ss>|<VC|vC|B|BVs|Vs>><v|V|v|<v(l|n|r)|vc>>(th)"
  res = form.submit
  names = res.body.scan(/\<td\>(\w+)\<\/td\>/)
  names[rand(names.length)].first
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

  on :message, /^!unsummon( #{$settings["settings"]["nick"]})?$/ do |m|
    if m.user == User($master)
      $irc.quit
      system("exit")
    end
  end

  on :message, /^!whois #{$settings['settings']['nick']}\s*/ do |m|
    m.reply "#{m.user.nick}: I am #{$settings['settings']['bot_master']}'s minion."
  end
end

$irc.start
