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
  vset = Set.new
  base = 3**k
  ksize = 2**(k-1)
  col0 = 2**k
  max_top_bits = 0
  bad = 0
  limit = 2 * 3**(k-1)
  (0...ksize).each do |i2|
    v = base * i2
    top = v / col0
    top_bits = top.size3
    #puts "#{v}  #{top.to_s(3)}  top: #{top_bits}"
    max_top_bits = top_bits if max_top_bits < top_bits
    vset.add v
    raise "bad #{i2}" unless top < limit
    #if limit / 2 < top
    #  puts "#{(top - limit / 2).to_s(3).reverse}"
    #end
  end

  w = (n / Math.log2(10) + 0.000001).ceil
  r = vset.size.to_f / ksize
  puts "%2d: top: %2d" % [k, max_top_bits]
  #puts "%2d:all %#{w}d / %#{w}d    %6.4f" % [k, vset.size, ksize, r]
  c_col0 = 0
  col0 = 2**k
  col0set = Set.new
  mcol0set = Set.new
  vset.each do |i|
    c_col0 += 1 if i < col0
    col0set.add i % col0
    mcol0set.add i / col0
  end
  #puts "  :n_col0 %#{w}d   %#{w}d   %#{w}d" % [c_col0, col0set.size, mcol0set.size]
  #puts "  #{mcol0set.max.to_s(3)}"
end
