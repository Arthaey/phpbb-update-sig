#!/usr/bin/env ruby
require "highline/import"
require "mechanize"
require "optparse"
require "./bbcode_progress.rb"
require "./phpbb.rb"

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "USAGE: #{$0} --username=USERNAME --site=URL --label=value[/max] ..."

  opts.on("-s", "--site=URL", "phpBB forum website URL") do |arg|
    arg.chop! if arg.end_with?("/")
    options[:site] = arg
  end

  opts.on("-u", "--username=USERNAME", "phpBB forum username") do |arg|
    options[:username] = arg
  end
end

# Keep any unknown options; these will be the progress items.
begin
  option_parser.parse!
rescue OptionParser::InvalidOption => e
  e.recover ARGV
end

raise "Username is required" if options[:username].nil?
raise "Site URL is required" if options[:site].nil?

password = ask("Password for #{options[:username]}: ") { |q| q.echo = false }
raise "Password required for user '#{options[:username]}'" if password.nil?

forum = PhpBB.new(options[:site], options[:username], password)
old_sig = forum.signature
new_sig = BBCodeProgress.update(old_sig, ARGV)

puts "\nOLD SIG:\n\n#{old_sig}"
if old_sig == new_sig
  puts "\nNo changes to sig."
  exit
end

forum.signature = new_sig
puts "\nNEW SIG:\n\n#{new_sig}"

