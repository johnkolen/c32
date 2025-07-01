class Integer
  def to_235
    i = 0
    n = self
    while n & 1 == 0
      i += 1
      n >>= 1
    end
    j = 0
    while n % 3 == 0
      j += 1
      n = n / 3
    end
    k = 0
    while n % 5 == 0
      k += 1
      n = n / 5
    end
    if n == 1
      [i, j, k]
    else
      nil
    end
  end
end

module C32
  class T235
    def initialize i, j, k
      @i = i
      @j = j
      @k = k
    end

    def to_s
      "<#{@i},#{@j},#{@k}>"
    end

    def to_i
      @ival ||= 2**@i * 3**@j * 5**@k
    end

    def self.minimal_terms n
      minimal(n).map{|x| T235.new *x.to_235 }
    end

    LOG_2 = Math.log(2)
    LOG_3 = Math.log(3)
    LOG_5 = Math.log(5)
    def self.minimal n
      @max_i = 0
      @max_j = 0
      @max_k = 0
      @block ||= []
      if @block.empty?
        @memo = {}
        x = Math.log(5000)
        max_i = (x / LOG_2).ceil
        max_j = (x / LOG_3).ceil
        max_k = (x / LOG_5).ceil
        unless max_i <= @max_i &&
               max_j <= @max_j &&
               max_k <= @max_k
          @max_i.upto(max_i) do |i|
            u = 2**i
            @max_j.upto(max_j) do |j|
              v = u * 3**j
              @max_k.upto(max_k) do |k|
                x = v * 5**k
                @block << x
              end
            end
          end
        end
      end
      @list = @block.select do |x|
        return [x] if x == n
        x <= n
      end
      @list.sort!
      sum = @list.sum
      #@list = @list.map{|x| [(sum += x), x]}
      #puts @list.inspect
      self.minimal_rec n, @list.size - 1, sum
    end

    BIG = 9999999
    def self.minimal_rec n, idx, csum, indent=""
      return nil if csum < n
      key = [n, csum]
      rv = @memo[key]
      return rv.dup if rv
      #puts "#{indent}#{n} @ #{idx}"
      return [] if n == 0
      raise "cain" if idx < 0
      cval = @list[idx]
      while n < cval
        idx -= 1
        #puts "#{indent}skip #{idx} n=#{n}  "
        csum -= cval
        cval = @list[idx]
      end
      return [n] if cval == n
      return @list[0..idx] if n == csum
      #puts "#{indent}"
      # skip the current
      ni = "#{indent}  "
      r1 = minimal_rec n, idx - 1, csum - cval, ni
      r1_size = r1 ? r1.size : BIG
      # take the current
      r2 = minimal_rec n - cval, idx - 1, csum - cval, ni
      r2_size = r2 ? r2.size : BIG
      rx = r1
      if r2_size < r1_size
        rx = r2.push(cval)
      end
      @memo[key] = rx.dup
      rx
    end
  end
end
