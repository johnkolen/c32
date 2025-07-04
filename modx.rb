#!/usr/bin/env ruby
require_relative "lib/c32"


n = (ARGV[0] || 3).to_i
m = (ARGV[1] || n).to_i
if n < m
  t = m
  m = n
  n = t
end
m += 1 if m.even?

z = C32::ModX.new m

z.table 10
