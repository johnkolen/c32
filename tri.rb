#!/usr/bin/env ruby
require_relative "lib/c32"


def layer n
  #puts "layer #{n}"
  raise "bad n = #{n}" if n < 0
  return if @layers[n]
  if false && n == 1
    # puts "[0, 0] = 1"
    @values = [0, 1]
    return
  end
  layer n - 1
  values = @layers[n - 1]
  # puts values.inspect
  n.times do |j|
    i = n - 1 - j
    v = 2**i * 3**j
    #puts "#{n}: [#{i}, #{j}] = #{v}"
    vx = values.map{|x| x + v}
    # puts vx.inspect
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

def iter n, min=1
  while true
    #print "#{n} "
    n = c(n)
    break if n <= min
    @visited << n
  end
  # puts n
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


@layers = [C32::VSet.new(0)]
# puts @layers.inspect

def time msg = nil, &block
  start = Time.now
  yield
  elapsed = Time.now - start
  if msg
    puts msg % elapsed
  else
    puts elapsed
  end
end
def process n

  layer n

  #puts @layers[n].size
  cutoff = @layers[n - 1].max
  u =  @layers[n - 1].map{|x| x.odd? ? 3 * x + 1 : x / 2}
  #puts "Layer #{n - 1}: #{@layers[n - 1].inspect}"
  #puts "Layer #{n - 1} xform: #{u.inspect}"
  #puts "Layer #{n}: #{@layers[n].inspect}"
  #puts "cutoff = #{cutoff}"
  z = (@layers[n] - @layers[n-1])
  @visited = Set.new
  z.each do |x|
    #print "#{x}: "
    iter x, cutoff
    cutoff = x
  end

  # @visited.union.sort.each do |x|
  #   puts "#{x} in #{layer_num x}"
  # end
  lx = @visited.map{|x| layer_num x}.union.sort
  puts "%2d: #{lx.inspect}" % [n]
end

m = n = 3
case ARGV[0]
when /\d+/
  n = ARGV[0].to_i
when /--table/
  n = ARGV[1].to_i
  m = (ARGV[2] || m).to_i
  m, n = [n, m] if n < m
end

m.upto(n) do |k|
  process k
end
