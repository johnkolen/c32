#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
def add_cell list, i, j
  v = 2**i * 3**j
  list << [list.last.first + v, v, i, j]
end

def drop list, i
  (0...i).map{ list.pop }.reverse.each do |x|
    sum, v, i, j = x
    i -= 1
    v = 2**i * 3**j
    list.push [list.last.first + v, v, i, j]
  end
end

def test n
  h = n + 2
  w = n
  top = []
  s = 0
  left = [[0]]
  (h-1).times {|i| add_cell left, i, 0}
  #puts left.inspect
  #puts left.last.first
  left_c = 2**(h-1) - 1
  top = [[0]]
  w.times {|j| add_cell top, h - 1, j }
  #puts top.inspect
  #puts top.last.first
  top_c = 2**(h-1) * (3**w - 1) / 2
  vacancies = top_c + left_c
  #puts "===="
  bottom = [[0]]
  (w+1).times {|j| add_cell bottom, -1, j }
  #puts bottom.inspect
  #puts bottom.last.first
  bottom_c = Rational(3**(w+1) - 1, 4)
  #puts bottom_c
  right = [[0]]
  (h-1).times {|i| add_cell right, i, w}
  #puts right.inspect
  #puts right.last.first
  right_c = 3**w * (2**(h  - 1) - 1)
  #puts right_c
  escapees = bottom_c.floor + right_c
  #puts "=" * 20
  #puts "0: #{escapees / vacancies.to_f}"
  final_i = 0
  (1...w).each do |i|
    drop top, i
    right.pop
    vacancies = left_c + top.last.first
    escapees = bottom_c.floor + right.last.first
    #puts "#{i}: #{escapees / vacancies.to_f}"
    final_i = i
    #break if escapees < vacancies
  end
  puts "#{"%2d" % n} bits: #{"%2d" % final_i} : #{"%6.4f" % (escapees / vacancies.to_f)}"
  top.shift
  puts "   #{left.last.inspect}"
  right.shift
  puts "   #{top.map{|x| [x[2],x[3]]}.inspect}  #{right.map{|x| [x[2],x[3]]}}"
  top_c = 4*(3**w - 2**w)
  puts "#{top_c} #{top.last.first}"
  right_c = 3**(w+1)
  puts "#{right_c} #{right.last.first}"
end

3.upto(10) do |i|
  test i
end
