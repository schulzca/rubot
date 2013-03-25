class LightsOut < PluginBase
  include Cinch::Plugin

	$help_messages << ["lights out","!lightout <number>  Start a game of lights out with a grid size of <number> (default 3)"]
	$help_messages << ["lights out","!lightout <row> <col>  Toggle the light at (<row>,<col>). (0,0) is top left"]

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  @games ||= {}
	  if active?(m,"lights_out")
      case m.message
      when /^!(lo|lightsout)(\s*(\d+))?\s*$/
        start_game(m, $3)
      when /^!(lo|lightsout)\s(\d)\s(\d)\s*$/
        take_turn(m, $3.to_i, $2.to_i)
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
    board = toggle_cell(board,row,column)
    if board.select{|r| r.select{|c| c}.any?}.any?
      reply(m,board_to_string(m))
      @games[m.user.nick]["board"] = board
    else
      reply(m, "#{m.user.nick}: You beat the #{size}x#{size} board in #{@games[m.user.nick]["turns"]} turns!")
      @games.delete m.user.nick
    end
  end

  def toggle_cell(board, row, column)
    size = board.size
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
    board
  end

  def colorize(m,val)
    if has_color?(m)
      return val ? "\x0309,03O\x03 " : "\x0307,04O\x03 "
    else
      return val ? "+ " : "~ "
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
        row << false
      end
      board += [row]
    end
    100.times do
      board = toggle_cell(board, rand(size),rand(size))
    end
    board
  end

  def has_color?(m)
    return !(m.channel && m.channel.modes["c"])
  end

end
