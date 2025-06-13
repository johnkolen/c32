#!/usr/bin/env ruby

n = 4
s = (0...n).map{|i| [0, i, i]}

def split s
  return s if s.size <= 2
  z = s[2..-1].map{|i, j, x| [i, j - 2, x]}
  s[0..1].concat( split(z)).concat(z.map{|i, j, x| [i + 3, j, x]})
end
def to_sum s
  x = s.map{|i, j, x| "x#{x}*2^#{i}*3^#{j}"}.
        join(" + ")
  x.gsub(/2\^0\*|\*3\^0/, "").
    gsub(/2\^0\*|\*3\^0/, "").
    gsub(/2\^1\*/, "2*").
    gsub(/\*3\^1/, "*3")
end
puts to_sum s
ss = split(s)
puts to_sum ss
puts to_sum(ss.sort)
