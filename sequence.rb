#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  if ARGV[0] == '-n'
    n = ARGV[1].to_i
  else
    n = VALUES[(ARGV[0] || 3).to_i - 3]
  end
  c = C32.new(n)
  c.iterate do |c|
    # puts c.to_s
    puts "#{c.to_i} #{c.ones} #{c.used} #{c.bits}   #{c.rsum}"
  end
end
