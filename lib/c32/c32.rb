# frozen_string_literal: true

module C32
  class C32
    attr_accessor :tbl
    attr_reader :zero

    def initialize n=nil, **options
      @tbl = []
      @zero = 0
      if options.empty?
        raise "missing n" if n.nil?
        while 0 < n
          @tbl.push n & 1
          n >>= 1
        end
      else
        options.each do |idx, v|
          while idx + @zero < 0
            @tbl.unshift 0
            @zero += 1
          end
          if idx.is_a? Integer
            @tbl[idx + @zero] = v
          end
        end
        @tbl[@tbl.size - @zero + 1] = 0
        0.upto(@tbl.size - 1) do |idx|
          @tbl[idx] ||= 0
        end
      end
      height = @tbl.size - @zero
      @tbl.unshift 0
      @zero += 1
      #(height - @zero).times do
      #  @tbl.unshift 0
      #end
      #@zero += (height - @zero)
      #@tbl.push 0
      #@max_bin_width = (@tbl.size - 1) / 2
    end

    alias old_dup dup
    def dup
      u = old_dup
      u.tbl = tbl.dup
      u
    end

    def width
      @tbl.map{|x| x.zero? ? 1 : Math.log2(x).ceil.to_i }.max
    end

    def fill_triangle
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      v = 1
      while @zero <= idx
        @tbl[idx] = v
        v += v + 1
        idx -= 1
      end
      self
    end

    def fill_square
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      v = 2**idx - 1
      while @zero <= idx
        @tbl[idx] = v
        idx -= 1
      end
      self
    end

    def fill_circle
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      r = idx
      while @zero <= idx
        u = Math.sqrt([0, r*r - (idx + 1)**2].max).ceil
        v = Math.sqrt(r*r - (idx )**2).ceil
        #puts "#{u}  #{v}"
        @tbl[idx] = 2**((u + v)/ 2) - 1
        idx -= 1
      end
      self
    end

    def fill_trapezoid
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      d = 0
      d = 1 if idx == 3
      d = 3 if idx == 5
      d = 1 if idx == 6
      v = 2**(((idx - @zero) / 4.0).ceil + d) - 1
      while @zero <= idx
        @tbl[idx] = v
        v += v + 1
        idx -= 1
      end
      self
    end

    def fill_ridge
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      v = 1
      while @zero <= idx
        @tbl[idx] = v
        v += v + 1
        idx -= 1
      end
      v >>= 1
      while 0 < v
        @tbl[idx] = v
        v >>= 1
        idx -= 1
      end
      self
    end

    def to_i
      c = 0
      @tbl.each_with_index do |z, idx|
        v = z.to_3
        c += z.to_3 * 2**(idx - @zero) unless v.zero?
      end
      c
    end

    def mul3
      @tbl = @tbl.map{|x| x << 1}
      self
    end

    def add1
      x = @tbl[@zero]
      raise "add1: space occupied" unless x & 1 == 0
      @tbl[@zero] |= 1
      self
    end

    def rotate
      [3, 5].each do |x|
        x3 = x.to_3
        xs = x
        if @tbl[@zero - 1].to_3 == x.to_3
          @tbl[@zero - 1] &= 0xFFFFFFFF ^ x
          i = @zero
          x3 >>= 1
          while 0 < x3
            # puts "--- #{x3}  #{x3  & 1}"
            if x3 & 1 == 1
              unless @tbl[i] & 1 == 0
                puts to_s
                raise "rotate: #{xs} "
              end
              @tbl[i] |= 1
            end
            i += 1
            x3 >>= 1
          end
          return
        end
      end
    end

    def fill_left n, idx
      hold = [n, idx]
      while 0 < n
        if @tbl[idx] & 1 == 1 && n & 1 == 1
          return self  # overwriting isn't allowed
        end
        n >>= 1
        idx += 1
      end
      n, idx = hold
      while 0 < n
        @tbl[idx] |= (n & 1)
        n >>= 1
        idx += 1
      end
      self
    end

    def adj_1
      changed = false
      check = to_i
      (@zero - 1).downto(0) do |base|
        u = @tbl[base - 1]
        next if u.zero?
        # 1      :
        # 1      :- equals 3
        # 01     2.to_3 = 3
        u = @tbl[base - 1]
        i1 = 1
        i0 = 1
        j = 1
        while 0 < u
          if u & 2 == 2  # 101.to_3 = 10
            if (@tbl[base + 1] & i1).zero? &&
               (@tbl[base] & i0).zero?
              @tbl[base + 1] |= i1
              @tbl[base] |= i0
              @tbl[base - 1] ^= (j * 2)
              changed = true
              puts "found 1 #{base}"
            else
              puts "found 1 but skipping #{base}"
            end
          end
          i0 <<= 1
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      if changed
        puts to_s
        raise "mismatch #{check} #{to_i}" if check != to_i
      end
      changed
    end

    def adj_11
      changed = false
      check = to_i
      (@zero - 1).downto(0) do |base|
        u = @tbl[base]
        next if u.zero?
        # 1      :
        # 0      :- equals 4
        # 11     to_3 = 4
        i1 = 1
        j = 1
        while 0 < u
          if u & 3 == 3
            if (@tbl[base + 2] & i1).zero?
              @tbl[base + 2] |= i1
              @tbl[base] ^= (j * 3)
              # take an extra step because 11 becomes 00
              i1 <<= 1
              j <<= 1
              u >>= 1
              changed = true
              puts "found 101 #{base}"
            else
              puts "found 11 but skipping #{base}"
            end
          end
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      if changed
        puts to_s
        raise "mismatch #{check} #{to_i}" if check != to_i
      end
      changed
    end

    def adj_101
      changed = false
      check = to_i
      (@zero - 1).downto(0) do |base|
        u = @tbl[base]
        # 1    :
        # 01   :- equals 10
        # 101  to_3 = 10
        i1 = 1
        i0 = 2
        j = 1
        while 0 < u
          if u & 5 == 5  # 101.to_3 = 10
            if (@tbl[base + 2] & i1).zero? &&
               (@tbl[base + 1] & i0).zero?
              @tbl[base + 2] |= i1
              @tbl[base + 1] |= i0
              @tbl[base] ^= (j * 5)
              changed = true
              puts "found 101 #{base}"
            else
              puts "found 101 but skipping #{base}"
            end
          end
          i0 <<= 1
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      if changed
        puts to_s
        raise "mismatch #{check} #{to_i}" if check != to_i
      end
      changed
    end

    def adj_1001
      changed = false
      check = to_i
      (@zero - 1).downto(0) do |base|
        u = @tbl[base]
        next if u.zero?
        # 1     :
        # 0110  :- equals 28
        # 1001  = 9.to_3 = 28
        i1 = 1
        i0 = 6
        j = 1
        while 0 < u
          if u & 9 == 9  # 101.to_3 = 10
            if (@tbl[base + 2] & i1).zero? &&
               (@tbl[base + 1] & i0).zero?
              @tbl[base + 2] |= i1
              @tbl[base + 1] |= i0
              @tbl[base] ^= (j * 9)
              changed = true
              puts "found 1001 #{base}"
            else
              puts "found 1001 but skipping #{base}"
            end
          end
          i0 <<= 1
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      if changed
        puts to_s
        raise "mismatch #{check} #{to_i}" if check != to_i
      end
      changed
    end

    def adj_10001
      changed = false
      check = to_i
      (@zero - 1).downto(0) do |base|
        u = @tbl[base]
        next if u.zero?
        # 1      :
        # 01110  :- equals 82
        # 10001  = 17.to_3 = 82
        i1 = 1
        i0 = 14
        j = 1
        while 0 < u
          if u & 17 == 17  # 101.to_3 = 10
            puts "#{base} #{u}"
            if (@tbl[base + 2] & i1).zero? &&
               (@tbl[base + 1] & i0).zero?
              @tbl[base + 2] |= i1
              @tbl[base + 1] |= i0
              @tbl[base] ^= (j * 17)
              changed = true
              puts "found 10001 #{base}"
            else
              puts "found 10001 but skipping #{base}"
            end
          end
          i0 <<= 1
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      if changed
        puts to_s
        raise "mismatch #{check} #{to_i}" if check != to_i
      end
      changed
    end

    def rotate
      0.upto(@zero - 1) do |base|
        next if @tbl[base] <= 1
        base = @zero - 1
        z = @tbl[base].to_3 / 2
        if 0 < z && z < 2**(@max_bin_width + @zero - base - 1)
          @tbl[base] = 0
          fill_left z, base + 1
        end
      end
      while adj_11 || adj_101 || adj_1001 || adj_10001 do
      end
      while adj_1 do
      end
      self
    end

    def rotate
      rv = @tbl[@zero - 1].to_3 / 2
      return if rv.zero?
      while 2**(@tbl.size - @zero) < rv
        i = (Math.log2(rv) / (1 + Math.log2(3))).to_i
        i = 0
        j = ((Math.log2(rv / 2**i)/Math.log2(3))).to_i
        #puts "rv = #{rv} i = #{i}"
        bv = 2**i * 3**j
        #puts "  2^#{i} 3^#{j} = #{bv}"
        bit = @tbl[@zero + i] & (1 << j)
        #puts "  bit = #{bit}"
        while !bit.zero?
          i += 1
          j = ((Math.log2(rv / 2**i)/Math.log2(3))).to_i
          bv = 2**i * 3**j
          bit = @tbl[@zero + i] & (1 << j)
        end
        if bit.zero?
          @tbl[@zero + i] |= (1 << j)
          rv -= bv
          #puts "   new rv = #{rv}"
        else
          break
        end
      end
      @tbl[@zero - 1] = 0
      p = 1
      (@zero...@tbl.size).each do |idx|
        rv += p * (@tbl[idx] & 1)
        p <<= 1
      end
      idx = @zero
      #puts "rv = #{rv}"
      while 0 < rv
        @tbl.push 0 if @tbl.size == idx
        if rv % 2 == 0
          @tbl[idx] >>= 1
          @tbl[idx] <<= 1
        else
          @tbl[idx] |= 1
        end
        rv >>= 1
        idx += 1
      end
    end

    def log3 x
      Math.log(x)/Math.log(3)
    end
    def ijval i, j
      2**i * 3**j
    end
    def add_at i, j, rv
      bit = @tbl[@zero + i] & (1 << j)
      if bit.zero?
        @tbl[@zero + i] |= (1 << j)
        return [i, j]
      end
      @tbl[@zero + i] ^= (1 << j)
      add_at i + 1, j, rv
    end

    def add_binary_column rv
      p = 1
      (@zero...@tbl.size).each do |idx|
        rv += p * (@tbl[idx] & 1)
        p <<= 1
      end
      idx = @zero
      #puts "rv = #{rv}"
      while 0 < rv
        @tbl.push 0 if @tbl.size == idx
        if rv % 2 == 0
          @tbl[idx] >>= 1
          @tbl[idx] <<= 1
        else
          @tbl[idx] |= 1
        end
        rv >>= 1
        idx += 1
      end
    end

    def rotate
      rv = @tbl[@zero - 1].to_3 / 2
      return if rv.zero?
      bc = 0
      p = 1
      (@zero...@tbl.size).each do |idx|
        bc += p * (@tbl[idx] & 1)
        p <<= 1
      end
      max_bc = 2**(@tbl.size - @zero) - 1
      #puts "rv #{rv}   bc #{bc}   max #{max_bc}"
      while max_bc - bc < rv
        i = 0
        j = log3(rv).to_i - 1
        break if j < 1
        add_at i, j, rv
        rv -= ijval i, j
      end
      @tbl[@zero - 1] = 0
      add_binary_column rv if 0 < rv
      return self
    end

    def div2
      unless @tbl.first == 0
        puts to_s
        raise "div2: falling off the cliff"
      end
      x = @tbl.shift
      @tbl.push x
      #rotate
      self
    end

    def iter
      if to_i % 2 == 1
        mul3.add1.div2.rotate
      else
        div2.rotate
      end
    end

    def bits
      @tbl.sum(&:bits)
    end

    def self.collatz n
      x = new(n)
      n = x.to_i
      stats = [[n, x.bits]]
      p = false
      nx = n
      max_width = x.width
      while 1 < n
        x.iter
        nx = nx / 2 + (nx % 2)*(nx + 1)
        n = x.to_i
        puts x.to_s if p
        raise "x.to_i = #{n}  nx = #{nx}" unless n == nx
        w = x.width
        max_width = w if max_width < w
        stats << [n, x.bits]
        if 0 < x.tbl[x.zero - 1]
          p = true
        end
      end
      [stats, x, max_width]
    end

    def to_s
      i = @tbl.size - 1
      while 0 <= i
        if i == @zero
          puts ">#{@tbl[i].to_s(2).reverse}"
        else
          puts " #{@tbl[i].to_s(2).reverse}"
        end
        i -= 1
      end
    end
  end
end
