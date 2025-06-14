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
        if true
          while 0 < n
            @tbl.push n & 1
            n >>= 1
          end
        else
          @tbl.push 0
          @tbl.push 0
          t = 1
          while 0 < n
            b = n % 3
            if b == 2
              @tbl[1] += t
            elsif b == 1
              @tbl[0] += t
            end
            t <<= 1
            n = n / 3
          end
        end
      else
        if options[:minimal]
          fill_with self.class.minimal_bits(options[:minimal])
        elsif options[:bits]
          fill_with options[:bits]
        else
          options.each do |idx, v|
            unless idx.is_a? Integer
              raise "#{idx} is not an integer"
            end
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

    def dimensions
      [@tbl.size - @zero, width]
    end

    def fill_with values
      values.each do |value|
        i = 0
        while value % 2 == 0
          i += 1
          value >>= 1
        end
        j = 0
        while value % 3 == 0
          j += 1
          value = value / 3
        end
        add_at i, j, 1
      end
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

    def fill_triangle
      #puts to_s
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      #puts "idx = #{idx}"
      bits = idx - @zero + 1
      k = 0 #6.0
      mask = 2**((bits + k / bits).ceil) - 1
      #puts "bits = #{bits}"
      #puts mask.to_s(2)
      bits = (1.45 * bits + k / bits).ceil
      bits = bits.ps3.to_s(2).size
      #puts "new bits = #{bits}"
      while @tbl.size - @zero + 1 < bits
        #puts "adding bit"
        @tbl.push 1
      end
      idx = @tbl.size - 1
      v = 1
      while @zero <= idx
        @tbl[idx] = v
        v += v + 1
        v &= mask
        idx -= 1
      end
      #puts to_s
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

    def fill_square
      idx = @tbl.size - 1
      idx -= 1 while @tbl[idx].zero?
      mask = 2**(idx) - 1
      v = mask >> (idx / 2).to_i
      while @zero <= idx
        @tbl[idx] = v
        v = ((v << 1) + 1) & mask
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
      d = 1
      #d = 1 if idx == 3
      #d = 3 if idx == 5
      #d = 1 if idx == 6
      v = 2**(((idx - @zero) / 4).ceil + d) - 1
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

    def or_eq otr
      while @zero < otr.zero
        @tbl.unshift 0
        @zero += 1
      end
      while @tbl.size - @zero < otr.tbl.size - otr.zero
        @tbl.push 0
      end
      @zero.upto(@tbl.size - 1) do |idx|
        t = otr.tbl[idx - @zero + otr.zero]
        break if t.nil?
        @tbl[idx] |= t
      end
      (@zero - 1).downto(0) do |idx|
        break if idx - @zero + otr.zero < 0
        t = otr.tbl[idx - @zero + otr.zero]
        @tbl[idx] |= t
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
      while @tbl.size - 1 < i + @zero
        @tbl.push 0
      end
      bit = @tbl[@zero + i] & (1 << j)
      if bit.zero?
        @tbl[@zero + i] |= (1 << j)
        return [i, j]
      end
      @tbl[@zero + i] ^= (1 << j)
      add_at i + 1, j, rv
    end

    def add_binary_column_dep rv
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

    def add_binary_column rv, col=0
      p = 1
      z = 1 << col
      (@zero...@tbl.size).each do |idx|
        rv += p * (@tbl[idx] & z)
        p <<= 1
      end
      idx = @zero
      #puts "rv = #{rv}"
      while 0 < rv
        @tbl.push 0 if @tbl.size == idx
        if rv % 2 == 0
          @tbl[idx] &= ~z
        else
          @tbl[idx] |= z
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

    def rotate
      rv = @tbl[@zero - 1].to_3 / 2
      return if rv.zero?
      bits = @tbl[@zero - 1].bits
      @tbl[@zero - 1] = 0
      if rv < 2**(@tbl.size - @zero - 1)
        add_binary_column rv
      else
        bx = 2**(@tbl.size - @zero - 1) - 1
        add_binary_column bx
        rv -= bx
        t = 0
        while 0 < rv
          b = rv % 3
          if b == 2
            add_at 1, t, 1
          elsif b == 1
            add_at 0, t, 1
          end
          t += 1
          rv = rv / 3
        end
        #puts "mimimal #{rv}"
        #values = self.class.minimal_bits rv
        #puts values.inspect
        #puts "before: #{bits}  after: #{values.size} #{bits < values.size ? 'inc' : ''}"
        #fill_with values
      end
      return self
    end

    def collapse
      z = @tbl[@zero]
      @tbl[@zero] &= 3
      u = z
      u >>= 2
      @tbl[@zero + 3] ||= 0
      while 0 < u
        add_at 0, 0, u & 1
        add_at 0, 1, u & 2
        v = u
        i = 0
        while 0 < v
          add_at 3, i, v & 1
          add_at 3, i+1, v & 2
          i += 2
          v >>= 2
        end
        u >>= 2
      end
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

    def iterate &block
      n = to_i
      while 1 < n
        yield self
        iter
        n = to_i
      end
      yield self
      self
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

    def self.minimal_bits_rec n, idx, values, bound=9999999, indent=""
      @calls += 1
      key = n
      if false && @memo[key]
        rv = @memo[key]
        return @memo[key] if rv.size <= bound
        return nil
      end
      return [] if n == 0
      return nil if bound <= 0
      if n < values[idx].first
        bs = values[0..idx].bsearch_index{|x| x.first > n }
        idx = bs ? bs - 1 : idx
      end
      node = values[idx]
      current, max_rest = node
      if max_rest < n
        #puts "#{indent}max rest block"
        return nil
      end
      if max_rest == n
        #puts "#{indent}max rest found"
        if values.size + 1 <= bound
          return values.map(&:first).push current
        end
        return nil
      end
      res = minimal_bits_rec n, idx - 1, values, bound, "  #{indent}"
      raise "cain #{bound} #{res.size}" if res && bound < res.size
      bound = res.size if res
      resp = minimal_bits_rec n - current,  idx - 1, values, bound - 1, "  #{indent}"
      raise "able" if resp && bound < resp.size
      #puts "#{indent}#{res.inspect} #{resp.inspect}"
      if !resp
        return res ? @memo[key] = res : nil
      end
      resp.push current
      return @memo[key] = resp if !res
      return @memo[key] = res if res.size <= resp.size
      return @memo[key] = resp
    end

    def self.calls
      @calls
    end
    def self.minimal_bits n
      max_j = (Math.log(n)/Math.log(3)).floor.to_i
      values = []
      max_j.downto(0) do |j|
        v = 3**j
        while v < n
          values.push v
          v *= 2
        end
      end
      s = 0
      values = values.sort.map{ |x| [x, s += x] }
      @calls = 0
      @memo ||= {}
      bound = 1
      nx = n
      while 1 < nx
        bound += 1 unless nx % 3 == 0
        nx = nx / 3
      end
      rv = minimal_bits_rec n, values.size - 1, values, bound
      #puts @memo.inspect
      rv
    end

    def self.footprint n
      x = new(n)
      fp = new(n)
      while 1 < n
        x.iter
        fp.or_eq x
        n = x.to_i
      end
      fp
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
