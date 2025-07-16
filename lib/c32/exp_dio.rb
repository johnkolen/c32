module C32
  class ExpDio
    def initialize x
      @x = x
      @a = [0]
      @sum = x
    end

    def value
      @sum / 2**@a.last
    end

    def to_s
      out = []
      if 1 < @a.size
        q = @a.pop
        @a.each_with_index do |a, i|
          out << "2^#{a}*3^#{i}"
        end
        @a.push q
      end
      out << "#{@x}*3^#{@a.size - 1}"
      "2^#{@a[-1]} = #{out.join(' + ')}"
    end

    def hyp?
      u = @x*3**(@a.size - 1)
      log_u = Math.log2(u).ceil
      #puts log_u
      #puts @a[-1]
      d = 2**@a[-1] - u
      puts "   2^#{@a[-1]} -  #{u} = #{d}" unless d < u
      log_u == @a[-1] && d < u
    end

    def iter!
      if value.odd?
        z = @a.last
        @a.unshift z
        @sum = 3 * @sum + 2**@a[0]
      end
      @a[-1] += 1
    end

    def iterate! &block
      while 1 < value
        iter!
        yield self if block_given?
      end
      self
    end
  end
end
