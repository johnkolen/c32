#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'

module C32
  n = (ARGV[0] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"

  fi = "%#{Math.log10(VALUES.size + 3).ceil}d"
  t = C32.new(VALUES.last << 2).fill_trapezoid.to_i.to_i
  fx = "%#{Math.log10(t).ceil + 1}d"
  fn = "%#{Math.log10(VALUES.last).ceil}d"
  puts fn
  VALUES.each_with_index do |n, idx|
    i = idx + 3
    #break if 3 < idx
    stats, c, width = C32.collatz n
    max_n = stats.map(&:first).max
    #puts stats.inspect
    t = C32.new(n << 2).fill_trapezoid.to_i.to_i
    bits = c.tbl.size - c.zero
    bad = t < max_n ? "bad" : ""
    puts "#{fi % i} #{fn % n} #{fx % max_n} #{fx % t}  #{bad}"
  end
end
