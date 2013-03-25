class Speak < PluginBase
  include Cinch::Plugin

	$help_messages << ["speak","!speak   Generate a random sentence from all of its stored grammar"]
	$help_messages << ["speak","!speak like <nick>   Generate a random sentence by using <nick>'s grammar"]

	listen_to :channel
	listen_to :private

	@@json = nil
	@@message_count = nil
  @@end_of_line = nil
  @@first = nil
  @@total = nil

  def initialize(*args)
    super
    unless @@json
      @@json = JSON.parse open($settings["settings"]["speak_path"]).read
      @@message_count = -1
      @@end_of_line = "<<<end of line>>>"
      @@first = "<<<first>>>"
      @@total = "<<<total>>>"
    end
  end

	def react_to_message(m)
	  if active?(m,"speak")
      @@message_count = (@@message_count + 1) % 10
      case m.message
      when /^!speak$/
        generate_grammar(m)
      when /^!speak like (.+)$/
        generate_grammar(m, $1)
      else
        store_grammar(m)
      end
      save_json if @@message_count == 0
    end
	end

  def generate_grammar(m, nick = nil)
    hash = nick ? @@json[":::#{nick}:::"] : eliminate_nick_dependance
    message = ""
    if hash
      key_two = get_random_word(hash[@@first])
      key_one = nil
      message = key_two
      until key_two.match @@end_of_line 
        new_word = get_random_word(hash["#{"#{key_one} " if key_one}#{key_two}"])
        key_one = key_two
        key_two = new_word
        message += " #{new_word}" unless new_word.match @@end_of_line
      end
    else
      message = "#{nick} has been silent."
    end
    reply m,message
  end

  def get_random_word(hash)
    total = hash[@@total]
    target = rand(total)
    word = nil
    hash.each do |key, value|
      unless key.match(@@total)
        if value > target
          word = key
          break
        else 
          target -= value
        end
      end
    end
    word
  end

  def eliminate_nick_dependance
    gen = {}
    @@json.each do |nick, key_hash|
      key_hash.each do |seed_word,result_hash|
        result_hash.each do |result_word,count|
          if gen[seed_word]
            if gen[seed_word][result_word]
              gen[seed_word][result_word] += count
            else
              gen[seed_word][result_word] = count
            end
          else
            gen[seed_word] = {result_word => count}
          end
        end
      end
    end
    gen
  end

  def store_grammar(m)
    if m.user
      words = m.message.split(/\s+/) << @@end_of_line
      one_ago = nil
      two_ago = nil
      nick = ":::#{m.user.nick}:::"
      @@json[nick] = {@@first => {@@total => 0}} unless @@json[nick]
      words.each do |word|
        word_key = "#{"#{two_ago} " if two_ago}#{one_ago}"
        word_key = @@first if word_key.empty?
        if @@json[nick][word_key]
          @@json[nick][word_key][@@total] += 1
          if @@json[nick][word_key][word]
            @@json[nick][word_key][word] += 1
          else
            @@json[nick][word_key][word] = 1
          end
        else
          @@json[nick][word_key] = {@@total => 1, word => 1}
        end
        two_ago = one_ago
        one_ago = word
      end
    end
  end

	def save_json
    File.open($settings["settings"]["speak_path"], 'w'){|f|f.write(@@json.to_json)}
  end
end
