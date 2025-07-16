#!/usr/bin/env ruby
require_relative "lib/c32"
require "matrix"

class ExpSearch
  attr_accessor :a
  attr_accessor :b
  attr_accessor :solutions

  def initialize x, m
    @m = m
    @x = x
  end

  def score
    aa = Vector[*@a.map{|x| 2**x}]
    aa.dot @b
  end

  def search_rec i, available, indent=""
    #puts "#{indent}rec #{i}, #{available}, #{@a.to_a.inspect}"
    if i == -1
      s = score
      #puts "#{indent}  #{s}:#{@tgt} #{@a.to_a.inspect} #{s==@tgt ? "bingo" : ""}"
      @solutions << @a.dup if s == @tgt
      return s == @tgt
      return false
    end
    return if available < i
    indent = "#{indent}  "
    prev = @a[i + 1] || 0
    1.upto(available) do |p|
      @a[i] = p + prev
      rv = search_rec i - 1, available - p, indent
      return rv if rv
    end
    false
  end

  def search
    @a = *Array.new(@m, 0)
    @b = Vector[*((0..(@m-1)).map{|i| 3**i})]
    @solutions = []
    @maxp = Math.log2(@x * 3**@m).ceil.to_i
    @tgt = 2**@maxp - @x * 3**@m
    puts "target = #{@tgt} = #{2**@maxp} - #{@x * 3**@m}"
    #puts "@a = #{@a.to_a.inspect}"
    @a[@m - 1] = 0
    search_rec @m - 2, @maxp
  end

  def soln
    u = []
    @a.each_with_index do |v, i|
      u << "2^#{v}*3^#{i}"
    end
    u << "#{@x}*3^#{@m}"
    "2^#{@maxp} = #{u.join(' + ')}"
  end
end


x = (ARGV[0] || 7).to_i
m = (ARGV[1] || 5).to_i

es = ExpSearch.new x, m
found = es.search
if found
  puts "found"
  puts es.soln
else
  puts "not found"
end
#puts "solutions: #{es.solutions.size}"

c = C32::Collatz.new x
prev = x
d = 0
c.iterate do |x|
  unless x < prev
    puts "mul  #{d}"
  end
  d += 1
  prev = x
end
puts "fin #{d}"
