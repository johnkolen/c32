#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  n = (ARGV[0] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"
  k = (ARGV[1] || 0).to_i
  puts "# k = #{k}"
  3.upto(n) do |i|
    cm = Collatz.max i
    t = C32.new(cm.last << (i / 6 + 2).to_i).fill_triangle.to_i.to_i
    r = C32.new(cm.last << (i / 6 + 2).to_i).fill_ridge.to_i.to_i
    bad = r < cm.first ? "r" : ""
    bad = t < cm.first ? "t #{bad}" : bad
    bad = "bad #{bad}" unless bad.empty?
    puts "#{fi % i} #{fm % cm.last} #{fx % cm.first} #{fx % t} #{fx % r}  #{bad}"
  end
end
