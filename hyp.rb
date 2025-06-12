#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  m = (ARGV[0] || 3).to_i
  n = (ARGV[1] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"
  tri = []
  tri_h = {}
  m.upto(2 * n) do |i|
    v = C32.new(2**i - 1).fill_triangle.to_i.to_i
    tri << [v, i]
    tri_h[i] = v
  end
  #puts tri.inspect

  m.upto(n) do |i|
    cm = Collatz.max i
    t = tri.each do |tx, b|
      break b if cm.first < tx
    end
    t = 99 unless t.is_a? Integer
    puts "#{fi % i} #{fm % cm.last} #{fx % cm.first} #{fi % t} #{fx % tri_h[t]}"
    STDOUT.flush
  end
end
