module C32
  class T3H
    attr_reader :i
    def initialize i=0
      @i = i
    end

    def md
      T3H.new @i + 1
    end

    def eql? otr
      @i == otr.i
    end

    def <=> otr
      @i <=> otr.i
    end

    def hash
      @i.hash
    end

    def to_s
      "<#{@i}>"
    end

    def to_r
      Rational(3**@i, 2**@i)
    end
  end

  class T3HBag < Hash
    def initialize n
      super
      t = T3H.new
      self[T3H.new] = n
    end

    def md!
      h = inject({}) do |h, (k, v)|
        h[k.md] = v
        h
      end
      clear
      h.each do |k, v|
        self[k] = v
      end
      self
    end

    def d!
      extra = {}
      zero = []
      each do |k, v|
        if false && ((v.integer? && v % 3 == 0) || v.numerator % 3 == 0)
          zero << k
          extra[k.md] = Rational(v, 3)
        else
          self[k] = Rational(v, 2)
        end
      end
      zero.each{|k| delete k}
      merge! extra
      self
    end

    def to_s
      keys.sort.inject([]) do |list, k|
        v = self[k]
        if v == 1
          list.push "#{k}"
        else
          list.push "#{v}*#{k}"
        end
      end.join(" + ")
    end

    def normalize
      c = Rational(1, map{|k,v| 2**-k.i * v}.min)
      c = c.to_i if c.denominator == 1
      x = keys.sort.map do |k|
        v = self[k]
        u = (2**-k.i) * c * v
        u = u.to_i if u.denominator == 1
        log_u = Math.log2(u).to_i
        if u == 2**log_u
          "2^#{log_u}*3^#{k.i}"
        else
          "#{u}*3^#{k.i}"
        end
      end.join(" + ")
      log_c = Math.log2(c).to_i
      if c == 2**log_c
        "2^#{log_c} = #{x}"
      else
        "#{c} = #{x}"
      end
    end

    def diff
      c = Rational(1, map{|k,v| 2**-k.i * v}.min)
      c = c.to_i if c.denominator == 1
      sum = 0
      keys.each do |k|
        v = self[k]
        u = (2**-k.i) * c * v
        sum += u * 3**k.i
        "#{u}*3^#{k.i}"
      end.join(" + ")
      sum = sum.to_i if sum.denominator == 1
      (c - sum) / c.to_f
    end

    def to_r
      inject(0) do |sum, (k, v)|
        sum + k.to_r * v
      end
    end

    def to_i
      r = to_r
      raise "#{r.inspect} is rational" unless r.denominator == 1
      r.to_i
    end

    def iter!
      if to_i.odd?
        md!
        t = T3H.new
        if key? t
          self[t] += Rational(1, 2)
        else
          self[t] = Rational(1, 2)
        end
      else
        d!
      end
      self
    end

    def iterate! &block
      while 1 < to_i
        iter!
        yield self if block_given?
      end
      self
    end
  end
end
