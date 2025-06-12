#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  n = (ARGV[0] || 10).to_i
  w = Math.log10(n).to_i + 1
  fi = "%#{w}d"
  fx = "%#{3 * n / 4}d"
  fm = "%#{Math.log10(2**n).to_i + 1}d"
  values = [7, 15, 31, 63, 111,255, 511, 703, 2047, 4095,
            6887, 14495, 31911, 60975, 113383, 239231, 487039,
            1042431, 1988859, 3873535, 7460635, 12589823,
            29457599, 57893375, 120080895, 246666523, 479707247,
            959414495, 2115185915, 4015548263, 8528817511]
  fi = "%#{Math.log10(values.size + 3).ceil}d"
  t = C32.new(values.last).fill_square.to_i.to_i
  fx = "%#{Math.log10(t).ceil + 1}d"
  fn = "%#{Math.log10(values.last).ceil}d"
  puts fn
  values.each_with_index do |n, idx|
    i = idx + 3
    #break if 3 < idx
    stats, c, width = C32.collatz n
    max_n = stats.map(&:first).max
    #puts stats.inspect
    t = C32.new(n).fill_square.to_i.to_i
    bits = c.tbl.size - c.zero
    bad = t < max_n ? "bad" : ""
    puts "#{fi % i} #{fn % n} #{fx % max_n} #{fx % t}  #{bad}"
  end
end
