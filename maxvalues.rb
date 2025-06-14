#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 3
  n = 3
  action = :two
  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
    m = (ARGV[1] || m).to_i
    m, n = [n, m] if n < m
  when /--three/
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
    action = :three
  end

  fi = "%#{Math.log10(n).to_i + 1}d"
  case action
  when :two
    fx = "%#{Math.log10(2**n).to_i + 1}d"
    fz = "%#{2 * Math.log10(2**n).to_i + 1}d"
    m.upto(n) do |i|
      finish, start = Collatz.max i
      label = (start + 1).bits == 1 ? "2^x-1" : ""
      puts "#{fi} #{fx} #{fz}   #{label}" % [i, start, finish]
      STDOUT.flush
    end
  when :three
    fx = "%#{Math.log10(3**n).to_i + 1}d"
    fz = "%#{2 * Math.log10(3**n).to_i + 1}d"
    m.upto(n) do |i|
      finish, start = Collatz.max3 i
      puts "#{fi} #{fx} #{fz} : %s : %s" % [i, start, finish, start.to_s(2), start.to_s(3)]
      STDOUT.flush
    end
  end
end
