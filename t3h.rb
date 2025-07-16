#!/usr/bin/env ruby
require_relative "lib/c32"


n = (ARGV[0] || 3).to_i
m = (ARGV[1] || n).to_i
if n < m
  t = m
  m = n
  n = t
end
m += 1 if m.even?

if m == n
  e = C32::ExpDio.new m
  e.iterate! do |e|
    puts "#{e.value}:  #{e}"
  end
  raise "bad hyp" unless e.hyp?
  exit
end
m.step(n, 2) do |k|
  e = C32::ExpDio.new k
  e.iterate!
  puts "%4d: #{e}" % k
  raise "bad hyp" unless e.hyp?
end

puts "=" * 20
exit
if m == n
  b = C32::T3HBag.new n
  puts "%4d: #{b.normalize}  diff=#{b.diff}" % b.to_i
  b.iterate! do |x|
    puts "%4d: #{x.normalize} diff=#{x.diff}" % x.to_i
  end
  exit
end
m.step(n, 2) do |k|
  b = C32::T3HBag.new k
  b.iterate!
  puts "%4d: #{b.normalize}" % k
end
