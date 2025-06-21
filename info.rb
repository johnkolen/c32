#!/usr/bin/env ruby

require_relative 'lib/c32'
m = 3
n = 3
unless ARGV.empty?
  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
    m = n
  when /--table/
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
  else
    puts "did not recognise args: #{ARGV.inspect}"
    exit 1
  end
end

m.upto(n) do |k|
  nset = Set.new
  noddset = Set.new
  col0 = 2**k
  max_top_bits = 0
  limit = 3**(k-2)
  (0...2**k).each do |i3|
    i2 = i3.from_3
    ni = (i2 & 1 == 1 ? (3*i2 + 1) : i2) / 2
    top = ni / col0
    top_bits = top > 0 ? top.size3 : 0
    max_top_bits = top_bits if max_top_bits < top_bits
    nodd = ni
    nodd >>= 1 until (nodd & 1).zero?
    #puts "%2d %#{n}s %2d => %3d => %3d top %3d" % [i3, i3.to_s(2), i2, ni, nodd, top_bits]
    nset.add ni
    noddset.add nodd
    raise "bad #{i3}" unless top < limit
  end

  w = (n / Math.log2(10) + 0.000001).ceil
  r = nset.size.to_f / 2**k
  #puts "%2d:all %#{w}d / %#{w}d    %6.4f" % [k, nset.size, 2**k, r]
  rodd = noddset.size.to_f / 2**k
  #puts "  :odd %#{w}d / %#{w}d           %6.4f" % [noddset.size, 2**k, rodd]
  #puts "  :top %2d" % [ max_top_bits ]
  c_col0 = 0
  col0set = Set.new
  mcol0set = Set.new
  nset.each do |i|
    c_col0 += 1 if i < col0
    col0set.add i % col0
    mcol0set.add i / col0
  end
  #puts "  :n_col0 %#{w}d   %#{w}d   %#{w}d" % [c_col0, col0set.size, mcol0set.size]
  #puts "  #{mcol0set.max.to_s(3)}"
  puts "%2d: %#{w}d / %#{w}d = %6.4f  col0: %#{w}d top: %2d" %
       [k, nset.size, 2**k, r, col0set.size, max_top_bits]
end
