#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 3
  n = 3
  bits = nil

  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
  when /--max/
    n = VALUES[ARGV[1].to_i - 3]
  end

  w = n.size2
  c = C32.new n
  c.iterate do |c|
    system 'clear'
    puts c.to_s
    puts " " * w + " |"
    puts "value = #{c.to_i}"
    puts "=" * w
    STDIN.gets
  end
end
