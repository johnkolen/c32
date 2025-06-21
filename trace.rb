#!/usr/bin/env ruby

require_relative 'lib/c32'
require_relative 'values'
module C32
  m = 3
  n = 3
  bits = nil
  h = {}

  case ARGV[0]
  when /\d+:\d+/
    while /(\d+):(\d+)/ =~ ARGV[0]
      h[$1.to_i] = $2.to_i
      ARGV.shift
    end
  when /\d+/
    n = ARGV[0].to_i
  when /--max/
    n = VALUES[ARGV[1].to_i - 3]
  end

  w = n.size2
  if h.empty?
    c = C32.new n
  else
    c = C32.new **h
  end
  c.iterate_fb do |c|
    system 'clear'
    puts c.to_s
    puts " " * w + " |"
    puts "value = #{c.to_i}"
    puts "=" * w
    q = STDIN.gets
    exit unless q
    if q.strip == "b"
      c.backward
    end
  end
end
