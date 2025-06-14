#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 5
  n = 31
  action = :all
  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
  when "--bits"
    n = 2**(ARGV[1].to_i)
  when "--trace"
    n = VALUES[ARGV[1].to_i - 3]
    action = :trace
  end

  case action
  when :all
    c = C32.new 1
    n.downto(m) do |i|
      c.or_eq C32.new minimal: i
    end
  when :trace
    c = C32.new minimal: n
    print "#{n}  "
    Collatz.new(n).iterate do |n|
      print "#{n}  "
      STDOUT.flush
      if 2 < n
        c.or_eq C32.new minimal: n
      end
    end
    puts
  end
  puts c.to_s
  puts c.dimensions.inspect
end
