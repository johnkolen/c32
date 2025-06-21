#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'

def to_3s v
  r = []
  bits = 0
  while 0 < v
    r.push v % 3
    return [nil, nil] if r.last == 2
    bits += 1 if r.last == 1
    v = v / 3
  end
  [bits, r.reverse.map(&:to_s).join]
end

module C32
  1.upto(3**10) do |i|
    rbits, r = to_3s 2 * i
    next if r.nil? || (rbits & 1) == 1
    bits = C32.minimal_bits(i)
    #puts "%-10s  %4d  %4d %-10s #{bits.inspect}" %
    #     [r.reverse, 2*i, i , i.to_s(2).reverse]
    if rbits <= bits.size
      puts "bad: %-10s  %4d  %4d %-10s #{bits.inspect}" %
           [r.reverse, 2*i, i , i.to_s(2).reverse]
      #q = 3**((Math.log(i)/Math.log(3)+0.000001).ceil)
      #puts "  #{(i * 2).to_s(3)} #{C32.minimal_bits(q).inspect}"
    end
  end
end
