#!/usr/bin/env ruby
require_relative "lib/c32"
def log3 n
  Math.log(n) / Math.log(3)
end

@memo = {}
def dbmin i, j, x
  return [] if x == 0
  return nil if i < 0 || j < 0
  m = @memo[[i,j,x]]
  return m if m

  v = 2**i * 3**j
  return [x] if v == x

  rv = [dbmin(i-1, j, x),
        dbmin(i, j-1, x)].compact
  if v < x
    r = dbmin(i-1, j, x - v)
    rv.push r.push(v) if r
    r = dbmin(i, j-1, x - v)
    rv.push r.push(v) if r
  end
  rv.sort{|a,b| a.size <=> b.size }
  @memo[[i,j,x]] = rv[0].dup
end

def even3 n, v=0, c=0
  if n == -1
    if c % 2 == 0
      xs = v.to_s(2).
            gsub("11","a0").
            gsub(/1([a0])([a0])1/,'b\1\20')

      x=xs.gsub("11","a0").gsub("22","b0").gsub("0","").size
      y=(v/2).to_s(3).gsub("0","").size
      z = 9999999
      if c < x && c < y
        z = dbmin @w - 1, @w - 1, v/2
        if c < z
          @failed += 1
          puts "#{c}:#{x}:#{y} #{v} #{v/2} #{(v/2).bits}  #{(v/2).to_s(2)} #{xs}"
          puts z
        end
      end
      @bits_in += c
      @bits_out += [x,y,z].min
    end
    return
  end
  even3 n - 1, v, c
  even3 n - 1, v + 3**n, c + 1
end

1.upto(10) do |k|
  v = 1 + 3**k
  v = v/2
  mx = dbmin k+1, k+1, v
  xs = v.to_s(2).
         gsub("11","a0").
         gsub(/1([a0])([a0])1/,'b\1\20')
  y=v.to_s(3).gsub("11","a0").gsub("22","b0").gsub("0","").size
  puts "#{v}  #{mx.inspect}  #{xs.gsub("0").size}  #{y}"
end
exit
5.upto(30) do |k|
  @bits_in = 0
  @bits_out = 0
  @failed = 0
  @w = k
  even3 k
  puts "#{k}: in: #{@bits_in} out: #{@bits_out}  failed: #{@failed}"
  if @bits_in < @bits_out
    puts "   failed"
  end
end
exit
n = 16

puts "n: #{n}"
left = 2**n
frac = (3**(n+1) - 1) / 2
puts "left: #{left} frac: #{frac}"
fwd = frac / left
puts "fwd: #{fwd}"

n = (log3(fwd) + 0.00001).ceil

puts "n: #{n}"
left = 2**(n)
frac = (3**(n+1) - 1) / 2
puts "left: #{left} frac: #{frac}"
fwd = frac / left
puts "fwd: #{fwd}"

n = (log3(fwd) + 0.00001).ceil

puts "n: #{n}"
left = 2**(n)
frac = (3**(n+1) - 1) / 2
puts "left: #{left} frac: #{frac}"
fwd = frac / left + 2**n
puts "fwd: #{fwd}"

n = (Math.log2(fwd) + 0.00001).ceil + 1

puts "n: #{n}"
left = 2**(n)
frac = (3**(n+1) - 1) / 2
puts "left: #{left} frac: #{frac}"
fwd = frac / left + 2**n
puts "fwd: #{fwd}"
