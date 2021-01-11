#!/usr/bin/env ruby

if ARGV.count < 1
  puts "* Make random line of specified file *"
  puts "Usage: #{__FILE__} want_to_random_line_file.txt"
  exit
end

file_path = ARGV[0]
puts "File '#{file_path}' not exist."; exit unless File.exist?(file_path)
arr = []

def setup_element(index, element)
  column = 3
  middle_total_length = 40
  start_space = ' ' * 4
  end_space = ' ' * 4

  real_length = element.to_s.length > middle_total_length ?
                 element.to_s.length : middle_total_length
  middle_rest_space = ' ' * (real_length - element.length)
  mod_number = index % column
  if mod_number == 0
    print "#{start_space}#{element}#{middle_rest_space}"
  elsif column - 1 == mod_number
    print "#{element}#{end_space}\n"
  else
    print "#{element}#{middle_rest_space}"
  end
end

File.open(file_path).each { |f| arr << f.strip unless f.strip.empty? }
arr.shuffle.each_with_index { |element, index| setup_element index, element }
