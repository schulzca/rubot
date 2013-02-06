class PluginManager < PluginBase
  include Cinch::Plugin

	listen_to :channel
	listen_to :private
	
	def react_to_message(m)
			begin
				case m.message
				when /^!update$/
				  if m.user.nick == $master
            reload_all(m)
          end
  			end
			rescue Exception => e
				error(m,e)
			end
	end

	def load_plugin(m, plugin, file_name)
    path = "plugins/#{file_name}.rb"
    unless File.exist?(path)
      debug "Expected #{plugin} to be at #{path}."
      return
    end

    begin
      load(path)
    rescue
      debug "Could not load #{plugin}."
      raise
    end

    begin
      const = Cinch::Plugins.const_get(plugin)
    rescue NameError
      debug "No class found for #{plugin}"
      return
    end

    @bot.plugins.register_plugin(const)
    debug "Loaded #{plugin}."
  end

	def unload_plugin(m,plugin)
    begin 
      plugin_class = Cinch::Plugins.const_get(plugin)
    rescue NameError
      pm User($master),"No #{plugin} class found."
      return
    end

    @bot.plugins.select {|p| p.class == plugin_class}.each do |p|
      @bot.plugins.unregister_plugin(p)
    end

    # Because we're not completely removing the plugin class,
    # reset everything to the starting values.
    plugin_class.hooks.clear
    plugin_class.matchers.clear
    plugin_class.listeners.clear
    plugin_class.timers.clear
    plugin_class.ctcps.clear
    plugin_class.react_on = :message
    plugin_class.plugin_name = nil
    plugin_class.help = nil
    plugin_class.prefix = nil
    plugin_class.suffix = nil
    plugin_class.required_options.clear

    debug "Unloaded #{plugin}."
  end
	
  def reload_all(m)
    classes = $settings["settings"]["plugins"].map {|plugin| plugin.split("_").map {|word| word.capitalize}.join("")} 
     #unload all but me
    classes.each do |p|
      unload_plugin(m, p) unless p == 'PluginManager'
    end

    #clear help messages
    $help_messages = []

     #update plugin list
    $settings = YAML.load(File.read("bot.yml"))
    names = $settings["settings"]["plugins"]
    classes = names.map {|plugin| plugin.split("_").map {|word| word.capitalize}.join("")} 

     #load all but me
    names.count.times do |index|
      load_plugin(m,classes[index], names[index]) unless names[index] == 'plugin_manager'
    end
    pm User($master),"Done updating."
  end

end
