#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  m = (ARGV[0] || 3).to_i
  n = (ARGV[1] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"
  m.upto(n) do |i|
    cm = Collatz.max i
    t = C32.new(cm.last).fill_triangle.to_i.to_i
    r = C32.new(cm.last).fill_ridge.to_i.to_i
    puts "#{fi % i} #{fm % cm.last} #{fx % cm.first} #{fx % t} #{fx % r}"
  end
end
