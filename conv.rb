#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
def add_cell list, i, j
  v = 2**i * 3**j
  list << [list.last.first + v, v, i, j]
end

module C32
  n = 18
  top = []
  s = 0
  (0...(n+2)).each { |i| v = 2**i; top << [s += v, v, i, 0] }
  #(1...n).each { |j| v = 2**(n-1)*3**j; top << [s += v, v, n-1, j] }
  (1...n).each { |j| add_cell top, n + 1, j}
  puts top.inspect
  s = 0
  bottom = []
  (0..n).each { |j| v = Rational(3**j, 2); bottom << [s += v, v, -1, j] }
  s = s.ceil
  (0...n).each { |i| v = 2**i * 3**n; bottom << [s += v, v, i, n] }
  puts bottom.inspect
  puts "#{top.last.first} > #{bottom.last.first}"
  exit
  puts "===="
  z = top.pop
  add_cell top, z[2]-1, z[3]
  bottom.pop
  puts top.inspect
  puts bottom.inspect
  puts "===="
  [top.pop, top.pop].reverse.each_with_index do |z, idx|
    add_cell top, z[2]-1, z[3]
  end
  bottom.pop
  puts top.inspect
  puts bottom.inspect
  puts "===="
  [top.pop, top.pop, top.pop].reverse.each_with_index do |z, idx|
    add_cell top, z[2]-1, z[3]
  end
  bottom.pop
  puts top.inspect
  puts bottom.inspect
  puts "===="
  [top.pop, top.pop, top.pop, top.pop].reverse.each_with_index do |z, idx|
    add_cell top, z[2]-1, z[3]
  end
  bottom.pop
  puts top.inspect
  puts bottom.inspect
end
