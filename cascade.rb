#!/usr/bin/env ruby
def log3 n
  Math.log(n) / Math.log(3)
end
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
