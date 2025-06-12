# frozen_string_literal: true

module C32
  class Collatz
    attr_accessor :n
    def initialize n
      @n = n
    end

    MAX_ITERS = 999999
    def max max_iters=MAX_ITERS
      max_x = @n
      iterate do |x|
        max_x = x if max_x < x
      end
      max_x
    end

    def iterate max_iters=MAX_ITERS, &block
      while 1 < @n && 0 < max_iters
        max_iters -= 1
        next_value
        yield @n if block_given?
      end
      self
    end

    def next_value
      @n = (@n >> 1) + (@n % 2)*(@n + 1)
      self
    end

    def self.max width
      high = (1 << width)
      low = high >> 1
      high -= 1
      #puts "low = #{low}  high = #{high}"
      low += 1
      list = (low..high).step(2).map { |x| [new(x), x] }
      max_cn = [high, high]
      while 1 < list.size
        #puts list.map{|c, n| "#{c.n}:#{n}"}.join(', ')
        list.delete_if { |c, n| c.next_value.n < n }
        break if list.empty?
        m = list.max { |a, b| #puts "#{a.inspect} <=> #{b.inspect}";
          [a.first.n, a.last] <=> [b.first.n, b.last] }
        #puts m.inspect
        max_cn = [m.first.n, m.last] if (max_cn <=> [m.first.n, m.last]) < 0
        #puts max_cn.inspect
      end
      unless list.empty?
        #puts list.map{|c, n| "#{c.n}:#{n}"}.join(', ')
        mx = list.last
        m = mx.first.max
        #puts "last m = #{m}"
        max_cn = [m, mx.last] if max_cn.first < m
        #puts max_cn.inspect
      end
      max_cn
    end

    def self.max width
      high = (1 << width)
      low = high >> 1
      high -= 1
      #puts "low = #{low}  high = #{high}"
      low += 1
      max_cn = [high, high]
      stepsize = 2**10
      list = []
      (low..high).step(stepsize).each do |blow|
        bhigh = [high, blow + stepsize + 1].min
        list = (blow..bhigh).step(2).map { |x| [new(x), x] }
        while 1 < list.size
          #puts list.map{|c, n| "#{c.n}:#{n}"}.join(', ')
          list.delete_if { |c, n| c.next_value.n < n }
          break if list.empty?
          m = list.max { |a, b| #puts "#{a.inspect} <=> #{b.inspect}";
            [a.first.n, a.last] <=> [b.first.n, b.last] }
          #puts m.inspect
          max_cn = [m.first.n, m.last] if (max_cn <=> [m.first.n, m.last]) < 0
          #puts "   #{max_cn.inspect}"
        end
        unless list.empty?
          #puts list.map{|c, n| "#{c.n}:#{n}"}.join(', ')
          mx = list.last
          m = mx.first.max
          #puts mx.inspect
          #puts "last m = #{m.inspect} #{mx.inspect}"
          max_cn = [m, mx.last] if max_cn.first < m || max_cn.first == m && max_cn.last < mx.last
          #puts max_cn.inspect
        end
      end
      max_cn
    end
  end
end
