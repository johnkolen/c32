#!/usr/bin/env ruby
require_relative "lib/c32"


module C32
n = (ARGV[0] || 3).to_i

VSet.new(0).each do |x|
  puts x
end

@layers = [VSet.new(0)]
puts @layers.inspect
def layer n
  #puts "layer #{n}"
  raise "bad n = #{n}" if n < 0
  return if @layers[n]
  if false && n == 1
    puts "[0, 0] = 1"
    @values = [0, 1]
    return
  end
  layer n - 1
  values = @layers[n - 1]
  puts values.inspect
  n.times do |j|
    i = n - 1 - j
    v = 2**i * 3**j
    #puts "#{n}: [#{i}, #{j}] = #{v}"
    vx = values.map{|x| x + v}
    puts vx.inspect
    values = values.union vx
  end
  @layers[n] = values
end

def c n
  if n.odd?
    3 * (n >> 1) + 2
  else
    n >> 1
  end
end

def layer_num x
  n = @layers.size - 1
  while !@layers[n].member?(x)
    n += 1
    layer n
  end
  while @layers[n].member? x
    n -= 1
  end
  return n + 1
end

@visited = []
def iter n, min=1

  while true
    #print "#{n} "
    n = c(n)
    break if n <= min
    @visited << n
  end
  #puts n
end

layer n
#puts @layers[n].inspect
#puts @layers[n].size
cutoff = @layers[n - 1].max
puts "cutoff = #{cutoff}"
(@layers[n] - @layers[n-1]).each do |x|
  #print "#{x}: "
  iter x, cutoff
  cutoff = x
end
#@visited.union.sort.each do |x|
#  puts "#{x} in #{layer_num x}"
#end
puts @visited.union.map{|x| layer_num x}.union.sort.inspect
end
