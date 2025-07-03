#!/usr/bin/env ruby
require_relative "lib/c32"

class ExpDio
  def initialize x
    @x = x
    @a = [0]
    @sum = x
  end

  def value
    @sum / 2**@a.last
  end

  def to_s
    out = []
    if 1 < @a.size
      q = @a.pop
      @a.each_with_index do |a, i|
        out << "#{2**a}*3^#{i}"
      end
      @a.push q
    end
    out << "#{@x}*3^#{@a.size - 1}"
    "#{2**@a[-1]} = #{out.join(' + ')}"
  end

  def iter!
    if value.odd?
      z = @a.last
      @a.unshift z
      @sum = 3 * @sum + 2**@a[0]
    end
    @a[-1] += 1
  end
end

n = (ARGV[0] || 3).to_i
m = (ARGV[1] || n).to_i
if n < m
  t = m
  m = n
  n = t
end
m += 1 if m.even?

e = ExpDio.new m
puts "#{e.value}:  #{e}"
e.iter!
puts "#{e.value}:  #{e}"
e.iter!
puts "#{e.value}:  #{e}"
e.iter!
puts "#{e.value}:  #{e}"

puts "=" * 20
#exit
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
