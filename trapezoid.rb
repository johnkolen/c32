#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
def pv i, j
  [i, j, 2**i * 3**j]
end
def process c
  w = c.fixed_width
  h = w + 2
  h += 1 if w <= 5
  puts w
  puts c.dimensions.inspect
  top = (0..(w-1)).map{|j| pv(h - 1 - j, j) }
  top_c = 4*(3**w - 2**w)*2**(h - (w+2))
  puts top.inspect
  puts "top: sum: #{top.map(&:last).sum} exp: #{top_c}"
  left = (0..(h-2)).map{|i| pv(i, 0)}
  puts left.inspect
  left_c = 2**(h-1) - 1
  puts "left: sum: #{left.map(&:last).sum} exp: #{left_c}"
  bottom = (0..w).map{|j| pv(-1, j) }
  puts bottom.inspect
  bottom_c = (3**(w+1)-1)/4
  puts "bottom: sum: #{bottom.map(&:last).sum} exp: #{bottom_c}"
  right = [pv(0, w), pv(1, w)]
  puts right.inspect
  right_c = 3**(w+1)
  puts "right: sum: #{right.map(&:last).sum} exp: #{right_c}"
  if bottom_c < top_c
    puts "divide ok"
  else
    puts "divide fails"
  end
  e = bottom_c + right_c
  v = top_c + left_c
  if e < v
    puts "multiply ok"
  else
    puts "multiply fails #{e} !< #{v}"
  end

end
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
    c = C32.new VALUES[n - 3]
    process c
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
