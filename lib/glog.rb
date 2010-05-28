require 'date'

class String
  def to_date
    if to_s =~ /(\d{4})-(\d{2})-(\d{2})/
      Date.new $1.to_i, $2.to_i, $3.to_i
    end
  end
end

class Glog
  def initialize(args = [])
    @args = args.dup
  end

  def no_color?; ARGV.include? '--no-color' end
  def no_hash?; ARGV.include? '--no-hash' end
  def today?; ARGV.include? '--today' end
  def recent?; ARGV.include? '--recent' end

  def colorize(text, color_code)
    no_color? ? text : "#{color_code}#{text}\033[0m"
  end

  def green(text); colorize(text, "\033[32m"); end
  def yellow(text); colorize(text, "\033[33m"); end
  def pink(text); colorize(text, "\033[35m"); end

  def write_log
    # git log --pretty=format:"%ad %b - (%an)" --date=short
    commits = `git log --pretty=format:"%ad|SPLIT|%s|SPLIT|%an|SPLIT|%h" --date=short`.split("\n").map do |commit|
      date, subject, author, hash = commit.split('|SPLIT|')
      {:date => date.to_date, :subject => subject, :author => author, :hash => hash }
    end

    commits = commits.select{|c| c[:date] >= Date.today - 1.day } if recent?
    commits = commits.select{|c| c[:date] == Date.today } if today?

    grouped_commits = commits.group_by{|c| c[:date] }
    grouped_commits.keys.sort.reverse.each do |date|
      puts pink(date.strftime('%Y-%m-%d %A'))
      grouped_commits[date].each do |commit|
        commit_line = "  "
        commit_line += "#{yellow(commit[:hash])}  " unless no_hash?
        commit_line += "#{commit[:subject]} (#{green(commit[:author])})"
        puts commit_line
      end
    end
    
  end
end