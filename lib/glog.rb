require 'date'

class String
  def to_date
    if to_s =~ /(\d{4})-(\d{2})-(\d{2})/
      Date.new $1.to_i, $2.to_i, $3.to_i
    end
  end
end

class Fixnum
  def minute; self * 60;         end; def minutes; minute; end
  def hour;   self * 60.minutes; end; def hours;   hour;   end
  def day;    self * 24.hours;   end; def days;    day;    end
  def week;   self * 7.days;     end; def weeks;   week;   end
  def month;  self * 30.days;    end; def months;  month;  end
end

class Glog
  def initialize(args = [])
    @args = args.dup
  end

  def no_color?; ARGV.include? '--no-color' end
  def hash?; ARGV.include? '--hash' end
  def today?; ARGV.include? '--today' end
  def recent?; ARGV.include? '--recent' end

  def colorize(text, color_code)
    no_color? ? text : "#{color_code}#{text}\033[0m"
  end

  def green(text); colorize(text, "\033[32m"); end
  def yellow(text); colorize(text, "\033[33m"); end
  def pink(text); colorize(text, "\033[35m"); end

  def log
    # git log --pretty=format:"%ad %b - (%an)" --date=short
    commits = `git log --pretty=format:"%ad|SPLIT|%s|SPLIT|%an|SPLIT|%h" --date=short`.split("\n").map do |commit|
      date, subject, author, hash = commit.split('|SPLIT|')
      {:date => date.to_date, :subject => subject, :author => author, :hash => hash }
    end

    commits = commits.select{|c| c[:date] >= Date.today - 1.day } if recent?
    commits = commits.select{|c| c[:date] == Date.today } if today?

    grouped_commits = commits.group_by{|c| c[:date] }
    commit_lines = []
    grouped_commits.keys.sort.reverse.each do |date|
      commit_lines << pink(date.strftime('%Y-%m-%d %A'))
      grouped_commits[date].each do |commit|
        commit_line = "  "
        commit_line += "#{yellow(commit[:hash])}  " if hash?
        commit_line += "#{commit[:subject]} (#{green(commit[:author])})"
        commit_lines << commit_line
      end
    end
    commit_lines
  end
end