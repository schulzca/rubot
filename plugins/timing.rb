class Timing < PluginBase
	include Cinch::Plugin

	$help_messages << "!timing     !start to start the stopwatch."
	$help_messages << "!timing     !stop to stop the stopwatch."
	$help_messages << "!timing     !lap to peek at the stopwatch."
	$help_messages << "!timing     !reset to reset the stopwatch."
	$help_messages << "!timing     !timer <number> to start a timer with <number> seconds."
	$help_messages << "!timing     !cencel to cancel the timer."

	listen_to :channel
	listen_to :private
	
	@@watches = {}
	@@timers = {}

	def listen(m)
	  if active?(m,"timing")
      begin
        case m.message
        when /^!timing( help)?$/
          help(m, "!timing")
        when /^!start$/
          start_stopwatch(m)
        when /^!stop$/
          stop_stopwatch(m)
        when /^!lap$/
          peek_stopwatch(m)
        when /^!timer\s+(\d+)/
          start_timer(m, $1.to_i)
        when /^!reset$/
          reset_stopwatch(m)
        when /^!cancel$/
          cancel_timer(m)
        end
      rescue Exception => e
        error(m,e)
      end
    end
	end

	def start_stopwatch m
    if @@watches[m.user.nick]
      m.reply "#{m.user.nick} already has a stopwatch running! Either !stop it or !reset it."
    else
      @@watches[m.user.nick] = Time.now
      m.reply "#{m.user.nick}'s stopwatch was started!"
    end
  end

  def stop_stopwatch m   
    time = @@watches[m.user.nick]
    if time
      m.reply "#{m.user.nick}'s stopwatch was stopped at #{format_time(time)}!"
      @@watches[m.user.nick] = nil
    else
      m.reply "#{m.user.nick} has no stopwatch to stop! First !start one."
    end
  end

  def peek_stopwatch m
    time = @@watches[m.user.nick]
    if time
      m.reply "#{m.user.nick}'s stopwatch is at #{format_time(time)}!"
    else
      m.reply "#{m.user.nick} has not started a stopwatch! First !start one."
    end
  end

  def reset_stopwatch m
    time = @@watches[m.user.nick]
    if time
      @@watches[m.user.nick] = Time.now
      m.reply "#{m.user.nick}'s stopwatch was restarted!"
    else
      m.reply "#{m.user.nick} has not started a stopwatch! First !start one."
    end
  end

  def start_timer m, time
    start = Time.now
    if @@timers[m.user.nick]
      m.reply "#{m.user.nick} already has a timer running!"
    else
      @@timers[m.user.nick] = true
      m.reply "#{m.user.nick}'s timer was started with #{format_time(start - time, true)}!"
      while !@@timers[m.user.nick] || Time.now < start + time

      end
      if @@timers[m.user.nick]
        @@timers[m.user.nick] = nil
        m.reply "#{m.user.nick}'s time is up!"
      end
    end
  end

  def cancel_timer m
    if @@timers[m.user.nick]
      @@timers[m.user.nick] = false
      m.reply "#{m.user.nick}'s timer was cancelled."
    else
      m.reply "#{m.user.nick} has no timer running."
    end
  end

  def format_time time, as_int = false
    time = Time.now - time
    minute = 60
    hour = 60 * minute
    day = 24 * hour
    week = 7 * day
    fortnight = 2 * week
    fortnights = (time/fortnight).to_i
    time -= fortnights*fortnight
    weeks = (time/week).to_i
    time -= weeks*week
    days = (time/day).to_i
    time -= days*day
    hours = (time/hour).to_i
    time -= hours*hour
    minutes = (time/minute).to_i
    time -= minutes*minute
    result = ""
    use_zero = false
    if fortnights > 0
      use_zero = true
      result = "#{fortnights} #{pluralize("fortnight", fortnights)}, "
    end
    if weeks > 0 or use_zero
      use_zero = true
      result = "#{result}#{weeks} #{pluralize("week",weeks)}, "
    end
    if days > 0 or use_zero
      use_zero = true
      result = "#{result}#{days} #{pluralize("day",days)}, "
    end
    if hours > 0 or use_zero
      use_zero = true
      result = "#{result}#{hours} #{pluralize("hour",hours)}, "
    end
    if minutes > 0 or use_zero
      use_zero = true
      result = "#{result}#{minutes} #{pluralize("minute",minutes)} and "
    end
    "#{result}#{as_int ? time.to_i : time} #{pluralize("second",time)}"
  end

  def pluralize word, number
    return "#{word}s" if number != 1
    word
  end
end
