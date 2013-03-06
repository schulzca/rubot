class LightsOut < PluginBase
  include Cinch::Plugin

	$help_messages << "!lights_out   play a game of lights out!"

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  @games ||= {}
	  if active?(m,"lights_out")
			begin
				case m.message
				when /^!help lights_out$/
					help(m, "!lights_out")
        when /^!(lo|lightsout)(\s*(\d+))?\s*$/
          start_game(m, $3)
        when /^!(lo|lightsout)\s(\d)\s(\d)\s*$/
          take_turn(m, $3.to_i, $2.to_i)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end

	def start_game(m, size = 3)
	  unless has_color?(m)
      reply(m, "Change mode to -c to make this game better.")
    end
    @games[m.user.nick] = {}
    @games[m.user.nick]["board"] = generate_board(size)
    @games[m.user.nick]["turns"] = 0
    size = @games[m.user.nick]["board"].length
    @games[m.user.nick]["size"] = size

    reply(m, "#{m.user.nick}: Started a #{size}x#{size} game of lights out.")
    reply(m, board_to_string(m))
  end

  def take_turn(m,row,column)
    unless @games[m.user.nick]
      reply(m, "#{m.user.nick}: Start a game first!")
      return
    end
    board = @games[m.user.nick]["board"]
    @games[m.user.nick]["turns"] += 1
    size = @games[m.user.nick]["size"]
    row = [row,0,size - 1].sort[1]
    column = [column,0,size - 1].sort[1]
    board[row][column] = !board[row][column]
    if row - 1 >= 0
      board[row-1][column] = !board[row-1][column]
    end
    if row + 1 < size
      board[row+1][column] = !board[row+1][column]
    end
    if column - 1 >= 0
      board[row][column-1] = !board[row][column-1]
    end
    if column + 1 < size
      board[row][column+1] = !board[row][column+1]
    end
    if board.select{|r| r.select{|c| c}.any?}.any?
      reply(m,board_to_string(m))
      @games[m.user.nick]["board"] = board
    else
      reply(m, "#{m.user.nick}: You beat the #{size}x#{size} board in #{@games[m.user.nick]["turns"]} turns!")
      @games.delete m.user.nick
    end

  end

  def colorize(m,val)
    if has_color?(m)
      return val ? "\x0309,03O\x03 " : "\x0307,04O\x03 "
    else
      return val ? "\x0309,03+\x03 " : "\x0307,04~\x03 "
    end
  end

  def board_to_string(m)
    if @games[m.user.nick]
      result = ""
      board = @games[m.user.nick]["board"]
      board.each do |row|
        result += "\x0301#{m.user.nick}: "
        row.each do |col|
           result += colorize(m,col)
        end
        result += "\n"
      end
      return result
    else
      return "But you don't have a game..."
    end
  end

  def generate_board(size)
    size = [size.to_i,3,7].sort[1]
    board = []
    size.times do 
      row = []
      size.times do
        row << (rand < 0.5)
      end
      board += [row]
    end
    board
  end

  def has_color?(m)
    return !(m.channel && m.channel.modes["c"])
  end

end
