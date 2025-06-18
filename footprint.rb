#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 3
  n = 3
  bits = nil
  action = :one
  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
  when /--table/
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
    action = :table
  when /--all/
    bits = ARGV[1].to_i
    n = 2**bits - 1
    m = 2**(bits - 1) + 1
    action = :all
  end

  case action
  when :one
    c = C32.footprint VALUES[n - 3]
    puts c.to_s
    puts c.to_i
    puts c.dimensions.inspect
    i = n
    exp_max = 3*(3**(i+2) - 1) / 2 - 2**(i+3) - 1 - 2*3**(i + 1)
    max_v = Collatz.new(VALUES[n - 3]).max
    puts "max: #{max_v} < #{exp_max}"
    if exp_max < max_v
      puts "bad"
    end
  when :all
    c = C32.footprint m
    (m + 2).step(n,2) do |i|
      c.or_eq C32.footprint i
    end
    cs = c.to_s
    puts cs
    puts c.to_i
    rows, cols =  c.dimensions
    puts "rows: #{rows}  cols: #{cols}"
    if bits < cols || cols + 2 < rows
      puts "****** VIOLATES HYPOTHESIS ******"
    end
  when :table
    m.upto(n) do |i|
      v = VALUES[i - 3]
      vbits = Math.log2(v)
      vtrits = (Math.log2(v)/Math.log2(3))
      max_v = Collatz.new(v).max
      max_v_bits = Math.log2(max_v).ceil.to_i
      c = C32.footprint v
      d = c.dimensions
      exp_max = 3*(3**(i+2) - 1) / 2 - 2**(i+3) - 1 - 2*3**(i + 1)
      puts "%2d %6.3f %6.3f %2d %2d x %2d" % [i, vbits, vtrits, max_v_bits, d.first, d.last]
      puts "   #{max_v} < #{exp_max}"
      STDOUT.flush
      if d.first > d.last + 2 || d.last > i
        #raise "cain"
      end
    end
  end
end
