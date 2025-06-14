#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 3
  n = 3
  action = :one
  case ARGV[0]
  when /\d+/
    n = ARGV[0].to_i
  when /--table/
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
    action = :table
  end

  case action
  when :one
    c = C32.footprint VALUES[n - 3]
    puts c.to_s
    puts c.to_i
    puts c.dimensions.inspect
  when :table
    m.upto(n) do |i|
      v = VALUES[i - 3]
      vbits = Math.log2(v)
      vtrits = (Math.log2(v)/Math.log2(3))
      max_v = Collatz.new(v).max
      max_v_bits = Math.log2(max_v).ceil.to_i
      c = C32.footprint v
      d = c.dimensions

      puts "%2d %6.3f %6.3f %2d %2d x %2d" % [i, vbits, vtrits, max_v_bits, d.first, d.last]
      STDOUT.flush
    end
  end
end
