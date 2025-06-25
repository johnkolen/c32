#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'

def leading n
  r = 0
  while n & 1 == 1
    r += 1
    n >>= 1
  end
  r
end

def process v, i=nil
  c = C32::Collatz.new v
  count = 0
  max_leading = leading v
  first_leading = max_leading
  c.iterate do |x|
    lx = leading x
    puts "#{x}  #{x.to_s(2)}" if max_leading < lx
    max_leading = lx if max_leading < lx
    #puts "#{x} #{x.to_s(2)} #{lx}"
    count += 1
    q = VALUES.index x
    if q
    puts "VALUES[#{q+3}] has predecessor"
    end
  end
  bad = (i && i < max_leading) ? '*' : ''
  puts "%2d: %4d  %2d:%2d  #{bad}" % [i||v, count, first_leading, max_leading]
end

module C32
  m = 3
  n = 3
  bits = nil
  action = :value
  case ARGV[0]
  when /^\d+/
    n = ARGV[0].to_i
    action = :table
  when "--table"
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
    action = :table
  when "--p2m1"
    bits = ARGV[1].to_i
    n = 2**bits - 1
    action = :one
  when "--table-p2m1"
    n = ARGV[1].to_i
    m = (ARGV[2] || m).to_i
    m, n = [n, m] if n < m
    action = :tablep2m1

  end

  case action
  when :table
    (m..n).each do |i|
      v = VALUES[i - 3]
      process v, i
    end
  when :tablep2m1
    (m..n).each do |i|
      v = 2**i - 1
      process v, i
    end
  when :one
    process n
  end
end
