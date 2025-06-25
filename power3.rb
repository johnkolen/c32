#!/usr/bin/env ruby

n = (ARGV[0] || 5).to_i

u = Hash.new {|h, k| h[k] = []}
rep = Hash.new {|h, k| h[k] = 0}
p = 1
n.times do |i|
  q = p
  j = 0
  while 0 < q
    if (q & 1) == 1
      u[j].push i
      rep[i] += 1
    end
    q >>= 1
    j += 1
  end
  p *= 3
end

u.keys.sort.each do |i|
  puts "#{i}: #{u[i].inspect}"
end
rep.keys.sort.each do |i|
  puts "#{i}: #{rep[i].inspect}"
end
