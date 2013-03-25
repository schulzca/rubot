require 'mechanize'

class Meme < PluginBase
  include Cinch::Plugin

  IMAGES = {"fry" => "Futurama-Fry",
            "sap" => "Socially-Awkward-Penguin",
            "socially awkward penguin" => "Socially-Awkward-Penguin",
            "success kid" => "Success-Kid",
            "sk" => "Success-Kid",
            "y u no" => "Y-U-No",
            "philosoraptor" => "Philosoraptor",
            "phil" => "Philosoraptor",
            "interesting" => "The-Most-Interesting-Man-In-The-World",
            "most intersting man in the world" => "The-Most-Interesting-Man-In-The-World",
            "willy" => "Willywonka",
            "willywonka" => "Willywonka",
            "forever alone" => "Forever-Alone",
            "fa" => "Forever-Alone",
            "one does not simply" => "One-Does-Not-Simply-A",
            "odns" => "One-Does-Not-Simply-A",
            "ggg" => "Good-Guy-Greg",
            "good guy greg" => "Good-Guy-Greg",
            "first world problems" => "First-World-Problems-Ii",
            "fwp" => "First-World-Problems-Ii",
            "scumbag steve" => "Scumbag-Steve",
            "ss" => "Scumbag-Steve",
            "insanity wolf" => "Insanity-Wolf",
            "iw" => "Insanity-Wolf",
            "grumpy cat" => "Grumpy-Cat-1",
            "gc" => "Grumpy-Cat-1",
            "bad luck brian" => "Bad-Luck-Brian-Meme",
            "blb" => "Bad-Luck-Brian-Meme",
            "what if i told you" => "What-If-I-Told-You-Meme",
            "wiity" => "What-If-I-Told-You-Meme",
            "all the things" => "All-The-Things",
            "att" => "All-The-Things",
            "yo dawg" => "Yo-Dawg",
            "yd" => "Yo-Dawg",
            "prepare yourself" => "Prepare-Yourself",
            "py" => "Prepare-Yourself",
            "annoying facebook girl" => "Annoying-Facebook-Girl",
            "afg" => "Annoying-Facebook-Girl",
            "conspiracy keanu" => "Conspiracy-Keanu",
            "ck" => "Conspiracy-Keanu",
            "i dont always" => "I-Dont-Always",
            "ida" => "I-Dont-Always",
            "stoner stanley" => "Stoner-Stanley",
            "correction guy" => "Correction-Guy",
            "cg" => "Correction-Guy",
            "troll face" => "Troll-Face",
            "tf" => "Troll-Face",
            "joseph decreux" => "Joseph-Ducreux",
            "jd" => "Joseph-Ducreux",
            "bad joke eel" => "Bad-Joke-Eels",
            "bje" => "Bad-Joke-Eels",
            "dat ass" => "Dat-Ass",
            "da" => "Dat-Ass"
  }

	$help_messages << ["meme","!meme <meme>|<top>|<bottom>   Generate a meme!"]
	$help_messages << ["meme","Available Meme Names: #{IMAGES.keys.sort.join(", ")}"]


	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"meme")
      case m.message
      when /^!meme (.+)\|(.+)\|(.*)$/
        generate_meme(m, $1, $2, $3)
      end
    end
	end
	
	def generate_meme(m, image, top, bottom)
	  image.strip!
	  top.strip!
	  bottom.strip!
	  if(IMAGES[image])
	    begin
        agent = Mechanize.new
        page = agent.get("http://www.memegenerator.net/#{IMAGES[image]}/caption")
        form = page.form(:action => "/#{IMAGES[image]}/caption")
        form.text0 = top
        form.text1 = bottom
        form.languageCode = "en"
        res = form.submit
        img = res.image(:class => /instance_large_img/)
        url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(img.src)}").read
        reply(m,"#{m.user.nick}: #{url}")
      rescue
        reply(m, "Sorry, memegenerator.net is down right now. Try again later.")
      end
    else
	    new_image = IMAGES.keys.sort_by{|option| closest_match(image,option)}.first
	    reply(m,"#{image} not available, did you mean #{new_image}?")
    end
	end
end
