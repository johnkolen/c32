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
        return parse(n) if n.is_a? String

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
      @width = to_i.size2
      @height = width + 2
      @tbl.unshift 0
      @zero += 1
      @max_side = 0
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

    def fixed_width
      @width
    end

    def set_fixed_width n
      @width = n
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
        v = z.from_3
        unless v.zero?
          d = z.from_3 * 2**(idx - @zero)
          c += d
          #puts ">#{idx - @zero} #{v}  #{d}  #{c}"
        end
      end
      c = c.to_i if c.is_a?(Rational) && c.denominator == 1
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

    def log3 x
      Math.log(x)/Math.log(3)
    end
    def ijval i, j
      2**i * 3**j
    end

    def row_sum i
      @tbl[i + @zero].from_3
    end

    def col_sum j
      s = 0
      @tbl.each_with_index do |v, idx|
        next if idx < @zero
        b = (v >> j) & 1
        s += b * 2**(idx - @zero)
      end
      s
    end

    def get_at i, j
      t = @tbl[i + @zero]
      return nil if t.nil?
      pwr = 2**j
      return 0 if t < pwr
      (t >> j) & 1
    end

    def set_at i, j, v
      while @tbl.size - 1 < i + @zero
        @tbl.push 0
      end
      bit = @tbl[@zero + i] & (1 << j)
      if v == 1
        @tbl[@zero + i] |= (1 << j)
      else
        @tbl[@zero + i] &= ~(1 << j)
      end
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

    def add_binary_column rv, col=0
      p = 1
      z = 1 << col
      (@zero...@tbl.size).each do |idx|
        rv += p * ((@tbl[idx] & z) >> col)
        p <<= 1
      end
      idx = @zero
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

    def rotate_ab z, exp
      @tbl[@zero - 1] = 0
      awidth = (2**@width - 1).size3
      a = z % 2**awidth
      a2 = a.from_3
      ac = a2 % 2
      add_binary_column a2 / 2
      b = z / 2**awidth
      b2 = b.from_3
      bc = b2 % 2
      add_binary_column b2 / 2, awidth
      return self if ac == 0 && bc == 0
      z = ac + bc * 2**awidth
      z.div32.each do |a|
        idx = @zero
        while 0 < a
          c = a & @tbl[idx]
          @tbl[idx] ^= c
          a ^= c
          @tbl[idx] |= a
          a = c
          idx += 1
        end
      end
    end

    def rotate_a z, exp
      @tbl[@zero - 1] = 0
      awidth = (2**@width - 1).size3
      a = z % 2**awidth
      a2 = a.from_3
      @ac = a2 % 2
      add_binary_column a2 / 2
      z / 2**awidth
    end

    def rotate_b b, exp
      b2 = b.from_3
      bc = b2 % 2
      awidth = (2**@width - 1).size3
      add_binary_column b2 / 2, awidth
      return self if @ac == 0 && bc == 0
      z = @ac + bc * 2**awidth
      z.div32.each do |a|
        idx = @zero
        while 0 < a
          c = a & @tbl[idx]
          @tbl[idx] ^= c
          a ^= c
          @tbl[idx] |= a
          a = c
          idx += 1
        end
      end
    end

    def rotate_b exp
      start = (2**@width - 1).size3
      v = 2**start
      #puts start
      #puts get_at -1, start
      while v <= @tbl[@zero - 1] do
        #puts "#{v} <= #{@tbl[@zero - 1].from_3}    #{@tbl[@zero - 1].to_s(2).reverse}"
        start.upto(@width) do |j|
          next unless 1 == get_at(-1, j)
          #puts "found #{j}"
          j.downto(start - 1) do |jj|
            next unless 1 == get_at(-1, jj)
            set_at -1, jj, 0
            add_at -1, jj - 1, 1
            add_at 0, jj - 1, 1
          end
          #puts to_s
          #puts "===="
          raise "bad after add b (#{@width})" unless exp == to_i
        end
      end
    end

    def extract_c exp
      cx = 0
      bits = 0
      px = 2**@width
      #puts to_s
      max_idx = 0
      @zero.upto(@tbl.size - 1) do |idx|
        excess = @tbl[idx] >> @width
        if 0 < excess
          cx += excess * 2**(idx - @zero)
          @tbl[idx] &= px - 1
          bits += 1
          max_idx = idx
          # puts "#{idx-@zero} #{excess}   #{cx}"
          if @max_side < idx - @zero
            @max_side = idx - @zero
            puts "max_side = #{@max_side}"
          end
        end
      end
      #raise "max idx = #{max_idx}" if 3 < max_idx - @zero
      cx *= 3**@width
      if 0 < cx
        #puts "cx: #{cx} rows: #{bits}"
      end
      raise "dropped something  #{@width}" unless to_i + cx == exp
      cx
    end

    def rotate_c exp
      cx = extract_c exp
      if 0 < cx
        r = crinkle cx
        # puts r.inspect
        delta = r.reverse.inject(0){|sum, x| 3 * sum + x }
        raise "cx != delta    #{cx} != #{delta}  width: #{@width}" unless cx == delta
        # puts "to_i=#{to_i} + #{cx} = #{exp}"
        # puts "to_i=#{to_i} + #{delta} = #{exp}"
        r.each_with_index do |u, j|
          add_binary_column u, j if 0 < u
        end
        raise "bad after add c  (#{@width})" unless exp == to_i
      end
    end

    def rotate_c_tri exp
      @zero.upto(@tbl.size - 1) do |idx|
        z = @tbl[idx]
        next if z.zero?
        z >>= @width
        next if z.zero?
        raise "too many bits" if 1 < z
        replace_tri idx - @zero, @width
        raise "bad value #{exp} != #{to_i}" if exp != to_i
      end
    end

    def rotate_c exp
      @zero.upto(@tbl.size - 1) do |idx|
        z = @tbl[idx]
        next if z.zero?
        z >>= @width
        next if z.zero?
        raise "too many bits" if 1 < z
        set_at idx - @zero, @width, 0
        i = idx - @zero
        j = @width - 1
        while 1 < j && i < @width - 1
          add_at i, j, 1
          i += 1
          j -= 1
        end
        add_at i, j, 1
        add_at i + 1, j, 1
        raise "bad value #{exp} != #{to_i}" if exp != to_i
        if @max_side < idx - @zero
          @max_side = idx - @zero
          #puts "max_side = #{@max_side}"
        end
      end
    end

    def dep_rotate
      exp = to_i
      z = @tbl[@zero - 1]
      return self if z.zero?
      z2 = z.from_3
      if z2 < 2**(@width + 1)
        @tbl[@zero - 1] = 0
        add_binary_column z2 / 2
      else
        #b = rotate_a z, exp
        #rotate_b b, exp
        rotate_b exp
        #puts "finished with b #{@tbl[@zero - 1].to_s(2).reverse}"
        rotate_a @tbl[@zero - 1], exp
        #puts "finished with a #{@tbl[@zero - 1].to_s(2).reverse}"
      end
      rotate_c exp
      if exp != to_i
        puts to_s
        raise "lost something  #{exp} != #{to_i}"
      end
      check_width
      self
    end

    def find_value_rec x, ary, idx
      return [] if x == 0
      return nil if ary.empty?
      while 0 <= idx &&  x < ary[idx].first
        idx -= 1
      end
      return nil if idx < 0
      v, i, j = ary[idx]
      r = find_value_rec x - v, ary, idx - 1
      return r.push [i, j] if r
      return find_value_rec x, ary, idx - 1
    end

    def find_value x, ary
      a = []
      ary.each do |i, j|
        v = 2**i * 3**j
        a.push [v, i, j] if v < x
        return [[i, j]] if v == x
      end
      a.sort!
      r = find_value_rec x, a, a.size - 1
      return r if r
      r = []
      while !a.empty? && 0 < x
        v, i, j = a.pop
        if v < x
          r << [i, j]
          x -= v
        end
      end
      r << [x] if 0 < x
      r
    end

    def rotate
      puts "rotate"
      check_trapezoid
      exp = to_i
      puts to_s
      erow = row_sum(-1) / 2
      ecol= col_sum(@width) * 3**@width
      e = erow  + ecol
      return self if e == 0
      # puts "exp = #{exp}"
      # puts "escapee row: #{erow}"
      # puts "escapee col: #{ecol}"
      ary = []
      available = 0
      h = @width + 2
      h += 2 if @width <= 5
      0.upto(h-2) do |i|
        break
        if 0 == (get_at(i, 0) || 0)
          ary.push [i, 0]
          available += 2**i
        end
      end
      0.upto(@width-1) do |j|
        i = h - 1 - j
        if 0 == (get_at(i, j) || 0)
          ary.push [i, j]
          available += 2**i * 3**j
        end
      end
      puts "available = #{available}"
      puts "e = #{e}"
      check_trapezoid

      # if available < e
      #   (@width - 1).downto(1) do |j|
      #     if 0 == (get_at(0, j) || 0)
      #       v = 3**j
      #       e -= v
      #       set_at(0, j, 1)
      #     end
      #     if 0 == (get_at(1, j) || 0)
      #       v = 2 * 3**j
      #       e -= v
      #       set_at(1, j, 1)
      #     end
      #   end
      #   puts "e now is #{e}"
      # end
      # if available < e
      #   (@width - 2).downto(1) do |j|
      #     if 0 == (get_at(2, j) || 0)
      #       v = 4 * 3**j
      #       e -= v
      #       set_at(2, j, 1)
      #     end
      #   end
      #   puts "e now is #{e}"
      #   puts to_s
      # end

      raise "need more " if available < e
      puts @width
      puts ary.inspect
      puts "e = #{e}"
      r = find_value e, ary
      puts r.inspect
      restored = 0
      @tbl[@zero - 1] = 0
      #puts "start #{to_i}"
      r.each do |i, j|
        if j
          raise "bit taken #{i},#{j}" if get_at(i, j) == 1
          puts "setting #{i}, #{j}"
          set_at i, j, 1
          check_trapezoid
          v = 2**i * 3**j
          restored += v
          #puts "#{v} #{to_i}"
        else
          puts "extra: #{i}"
          puts to_s
          add_binary_column i
          check_trapezoid
        end
      end
      puts "restored = #{restored}"
      puts "to_i (fract = 0): #{to_i}"
      if 0 < ecol
        puts "setting ecol"
        (h-@width + 1).times do |i|
          set_at i, @width, 0
          raise "cain" unless get_at(i, @width) == 0
        end
      end
      check_trapezoid
      if exp != to_i
        puts to_s
        raise "exp != to_i:  #{exp} != #{to_i}"
      end
      raise "cain" unless r
    end
    def check_width
      if @width < width
        puts to_s
        raise "width broken #{@width} < #{width}"
      end
    end

    def check_trapezoid
      h = @width + 2
      h += 2 if @width <= 5
      (h...@tbl.size).each do |i|
        r = @tbl[h + @zero]
        if r && 0 < r
          puts to_s
          raise "trapezoid violation #{i},#{0} for width = #{@width} height = #{h}"
        end
      end
      @width.times do |j|
        i = h - j - 1
        #puts [i,j].inspect
        if 1 < ((@tbl[@zero + i] || 0) >> j)
          puts to_s
          puts @tbl[@zero + h - j - 1].to_s(2).reverse
          raise "trapezoid violation #{i},#{j} for width = #{@width} height = #{h}"
        end
      end
    end

    def replace i, j
      v = get_at i,j
      return self if v == 0
      set_at i, j, 0
      (0...j).each do |jx|
        add_at i + 1, jx, 1
      end
      add_at i, 0, 1
      self
    end

    def replace_tri i, j
      v = get_at i,j
      return self if v == 0
      set_at i, j, 0
      tri = []
      s = 0
      0.upto(@width-1) do |u|
        0.upto(u) do |j|
          v = 2**(u - j) * 3**j
          s += v
          tri << [s, v, u - j, j]
        end
      end
      z = 2**i * 3**j
      while 1 < z
        idx = tri.last.first <= z ?
                tri.size :
                tri.bsearch_index{|x| x.first >= z}
        t = tri[idx - 1]
        idx.times {|i| add_at tri[i][2], tri[i][3], 1 }
        z -= t.first
      end
      add_at 0, 0, 1 if z == 1
      self
    end

    def max_ij
      m = 0
      (@zero...@tbl.size).each do |idx|
        i = idx - @zero
        j = 0
        z = @tbl[idx]
        while 0 < z
          if 0 < z & 1
            v = i + j
            m = v if m < v
          end
          j += 1
          z >>= 1
        end
      end
      m
    end

    def crinkle n
      r = []
      q = 2**(@width + 1)
      base = 1
      sum = 0
      x = n
      while q <= n
        v = n % q
        bc = v % base
        s = 0
        # puts "    v = #{v} = #{base} * #{v/base} + #{bc}"
        if 0 < bc
          j = -1
          sum += bc
          s += bc
          basex = base / 3
          while 0 < bc
            bcx = bc / basex
            r[j] += bcx
            bc = bc % basex
            basex = basex / 3
            j -= 1
          end
        end
        r << (v / base)
        sum += (v / base) * base
        s += (v / base) * base
        n -= v
        raise "bad" unless x == sum + n
        rs = r.reverse.inject(0){|sum, x| 3 * sum + x }
        # puts "    #{sum}  #{rs}"
        raise "r bad #{sum} != #{rs}" unless sum == rs
        q >>= 1
        q *= 3
        base *= 3
      end
      #puts "rs = #{rs} n = #{n} :#{rs + n}  #{x}"

      idx = r.size
      p3 = 3**idx
      while 0 < n
        r[idx] = 0 if r.size <= idx
        v = n / p3
        r[idx] += v
        sum += v * p3
        n -= v * p3
        idx -= 1
        p3 = p3 / 3
      end
      r.pop while r.last == 0
      while @width < r.size
        u = r.pop
        r = r.map{|x| 2 * u + x}
        r[0] += u
      end
      if false && 4 < r[-1]
        u = r.pop - 3
        r = r.map{|x| 2 * u + x}
        r[0] += u
        r.push 3
      end
      r
    end

    def split max_row, start
      changed = false
      0.upto(max_row) do |row|
        idx = row + @zero
        col = start
        b = 1 << col
        while b < @tbl[idx]
          if 0 < @tbl[idx] & b
            @tbl[idx] ^= b
            add_at row, col - 1, 1
            add_at row + 1, col - 1, 1
            changed = true
          end
          b <<= 1
          col += 1
        end
      end
      changed
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
      check_trapezoid
      if to_i % 2 == 1
        puts "************ #{to_i}"
        puts to_s
        m = mul3
        puts to_s
        a = m.add1
        puts to_s
        a.div2.rotate
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
      out = []
      while 0 <= i
        if i == @zero
          out << ">#{@tbl[i].to_s(2).reverse}"
        else
          out << " #{@tbl[i].to_s(2).reverse}"
        end
        i -= 1
      end
      out.join("\n")
    end

    def parse str
      @zero = 0
      str.each_line do |line|
        v = 0
        @zero += 1
        line.reverse.each_char do |c|
          case c
          when '1'
            v = 2 * v + 1
          when '0'
            v = 2 * v
          when '>'
            @zero = 0
          end
        end
        @tbl.push v
      end
      @tbl.reverse!
    end
  end
end
