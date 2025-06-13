#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  n = (ARGV[0] || 3).to_i
  c = C32.footprint VALUES[n - 3]
  puts c.to_s
  puts c.to_i
end
