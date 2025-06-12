#!/usr/bin/env ruby

require_relative 'lib/c32'

module C32
  values = [7, 15, 31, 63, 111,255, 511, 703, 2047, 4095,
            6887, 14495, 31911, 60975, 113383, 239231, 487039,
            1042431, 1988859, 3873535, 7460635, 12589823,
            29457599, 57893375, 120080895, 246666523, 479707247,
            959414495, 2115185915, 4015548263, 8528817511]
  fi = "%#{Math.log10(values.last).ceil}d"
  fx = "%#{Math.log10(Math.log2(values.last).ceil).ceil}d"
  values.each do |n|
    stats, c, width = C32.collatz n
    bits = c.tbl.size - c.zero
    puts "#{fi % n} #{fx % Math.log2(n).ceil} #{fx % bits} #{fx % width}"
  end
end
