class BaseMath < PluginBase
  include Cinch::Plugin

	$help_messages << ["math", "Enter a math expression to have it evaluated."]
	$help_messages << ["math", "Preface numbers with '0x' for hex, '0d' for decimal(defaul), '0o' for octal, and '0b' for binary."]
	$help_messages << ["math", "Allowed operators: [+,-,*,/,**(power),|(bitwise or),^(bitwise xor),%,&(bitwise and),()]"]
	$help_messages << ["math", "Flags: '-r #' => Result in base # (2..36), '-d #' => Unmarked numbers are in base # (2..36, default 10)"]

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"base_math")
      case m.message
      when /^!math ([0-9a-fxor+\-*\/|\^%&()\s]+)\s*$/
        evaluate(m,$1)
      when /^!math (.*)$/
        explain_failure(m,$1)
      end
    end
	end
	
	def evaluate(m,exp)
	  exp = exp.gsub /([0-9])\s*\(/ do
      "#{$1} * ("
    end
    exp = exp.gsub /\)\s*([0-9])/ do
      ") * #{$1}"
    end
    exp = exp.gsub(/-r (\d+)/,"")
    @result_base = [$1 ? $1.to_i : 10, 2, 36].sort[1] #clamping result base between 2 and 36
    exp = exp.gsub(/-d (\d+)/,"")
    @default_base = [$1 ? $1.to_i : 10, 2, 36].sort[1] #clamping default base between 2 and 36 
    
    exp = exp.gsub /\b(-?[0-9]+)\b/ do
      $1.to_i(@default_base).to_s
    end

    result = eval(exp).to_s(@result_base)
    reply(m, "#{m.user.nick}: #{result.upcase}")
	end

  def explain_failure(m,exp)
    valid_chars = %w(0 1 2 3 4 5 6 7 8 9 a b c d e f o x + - * / | ^ % & ( )) 
    valid_chars.each do |char|
      exp = exp.gsub(char, "")
    end
    reply(m, "Invalid charaters were found: [#{exp.split(/\s+/).uniq.join(", ")}]")
  end
end
