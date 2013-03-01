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
            "iw" => "Insanity-Wolf"}

	$help_messages << "!meme <meme>|<top>|<bottom>   Generate a meme!"
	$help_messages << "!meme Available Meme Names: #{IMAGES.keys.join(", ")}"


	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"meme")
			begin
				case m.message
				when /^!help meme$/
					help(m, "!meme")
        when /^!meme (.+)\|(.+)\|(.+)$/
          generate_meme(m, $1, $2, $3)
  			end
			rescue Exception => e
				error(m,e)
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
        reply(m, "Sorry, memegenerator.com is down right now. Try again later.")
      end
    else
	    new_image = IMAGES.keys.sort_by{|option| closest_match(image,option)}.first
	    reply(m,"#{image} not available, did you mean #{new_image}?")
    end
	end
end
