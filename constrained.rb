#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'

def work n
  print "%2d: " % n
  c = C32::C32.new 2**n
  n.times{ |i| c.tbl[c.zero + i] = 2**n - 1}
  (n-1).times{ |i| c.tbl[c.zero + i + n] = 2**(n - i - 1) - 1}
  max_i = c.to_i
  i = 3
  while i <= max_i do
    (2*n).times{ |i| c.tbl[c.zero + i] = 0}
    bits = C32::C32.minimal_bits(i, rect:[2*n, n])
    raise "no bits for #{i}" unless bits
    bits.map(&:to_ij).each do |i,j|
      c.set_at(i, j, 1)
    end
    if c.to_i != i
      print "[#{i}]"
      STDOUT.flush
      break
    else
      begin
        c.iterate
      rescue RuntimeError
        print "#{i} "
        STDOUT.flush
        break
      end
    end
    i += 2
  end
  puts
end

m = 3
n = 3
case ARGV[0]
when /\d+/
  n = ARGV[0].to_i
  m = n
when /--table/
  n = ARGV[1].to_i
  m = (ARGV[2] || m).to_i
  m, n = [n, m] if n < m
  action = :table
end
m.upto(n) do |i|
  work i
end
