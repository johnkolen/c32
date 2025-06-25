#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  action = :c32
  if ARGV[0] == '-c'
    action = :collatz
    ARGV.shift
  end
  case ARGV[0]
  when '-n'
    n = ARGV[1].to_i
  when '--p2m1'
    n = 2**(ARGV[1].to_i) - 1
  else
    n = VALUES[(ARGV[0] || 3).to_i - 3]
  end

  case action
  when :c32
    c = C32.new(n)
    c.iterate do |c|
      puts c.to_s
    end
  when :collatz
    c = Collatz.new(n)
    c.iterate do |c|
      puts c
    end
  end
end
