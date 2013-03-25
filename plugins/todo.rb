class Todo < PluginBase
  include Cinch::Plugin

	$help_messages << ["todo","!todo add <message>          add an item to your list"]
	$help_messages << ["todo","!todo finish <item number>   remove an item"]
	$help_messages << ["todo","!todo <number>               view the <number> item on your list"]
	$help_messages << ["todo","!todo list                   view all items"]
	$help_messages << ["todo","!todo clear                  finish all items"]

	listen_to :channel
	listen_to :private
	
  @@json = nil
  @writing_to_file = false
  def initialize(*args)
    super
    unless @@json
      @@json = JSON.parse open($settings["settings"]["todo_path"]).read
    end
  end
	
	def react_to_message(m)
	  if active?(m,"todo")
      case m.message
      when /^!todo add (.+)$/
        store_item(m,$1)
        write_json
      when /^!todo finish (\d+)$/
        finish_item(m,$1.to_i)
        write_json
      when /^!todo (\d+)$/
        view_item(m,$1.to_i)
      when /^!todo list$/
        view_all(m)
      when /^!todo clear$/
        finish_all(m)
        write_json
      end
    end
	end

	def view_all(m)
	  items = @@json[m.user.nick]
	  if items and items.any?
      items.size.times do |i|
        pm(m.user,get_item(m,i + 1))
      end
    else
      pm(m.user,"#{m.user.nick}: You have no stored items.")
    end
  end

	def get_item(m,number)
    message = ""
    items = @@json[m.user.nick]
    if items
      if number > 0 and number <= items.size
        "#{m.user.nick}: [#{number}] #{items[number - 1]}" 
      elsif number < 1
        "#{m.user.nick}: The item number must be positive."
      else
        "#{m.user.nick}: You only have #{items.size} item(s)."
      end
    else
      "#{m.user.nick}: You have no stored items."
    end
  end

  def view_item(m,number)
    reply(m,get_item(m,number))
  end

	def finish_all(m)
    @@json[m.user.nick] = []
  end

	def finish_item(m,number)
    message = ""
    items = @@json[m.user.nick]
    if items
      if items.size >= number and number > 0
        items.delete_at(number - 1)
        @@json[m.user.nick] = items
      elsif number < 1
        message = "#{m.user.nick}: The item number must be positive."
      else
        message = "#{m.user.nick}: You only have #{items.size} item(s)."
      end
    else
      message = "#{m.user.nick}: You have no stored items."
    end
    reply(m,message) unless message.empty?
  end

	def store_item(m,item)
    if @@json[m.user.nick]
      @@json[m.user.nick] << item
    else
      @@json[m.user.nick] = [item]
    end
    reply(m,"#{m.user.nick}: You now have #{@@json[m.user.nick].size} item(s) in your list.")
  end

	def write_json
    unless @writing_to_file
      @writing_to_file = true
      File.open($settings["settings"]["todo_path"], 'w'){|f|f.write(@@json.to_json)}
      @writing_to_file = false
    end
  end
end
