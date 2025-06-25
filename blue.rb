#!/usr/bin/env ruby

def c(x)
  if x.odd?
    (3 * x  + 1 ) /2
  else
    x / 2
  end
end
k = 9
x = 31
mask = 2**k - 1
seen = Set.new
while 1 < x && !seen.member?(x)
  seen.add x
  puts x
  x = c(x) & mask
end
puts x
