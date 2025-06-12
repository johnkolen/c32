#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  n = (ARGV[0] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"
  3.upto(n) do |i|
    cm = Collatz.max i
    t = C32.new(cm.last).fill_trapezoid.to_i.to_i
    bad = t < cm.first ? "t" : ""
    bad = "bad #{bad}" unless bad.empty?
    puts "#{fi % i} #{fm % cm.last} #{fx % cm.first} #{fx % t} #{bad}"
    STDOUT.flush
  end
end
