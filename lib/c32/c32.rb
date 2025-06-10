# frozen_string_literal: true

module C32
  class C32
    attr_accessor :tbl
    attr_reader :zero

    def initialize n
      @tbl = []
      while 0 < n
        @tbl.push n & 1
        n >>= 1
      end
      @zero = @tbl.size
      @tbl.size.times do
        @tbl.unshift 0
      end
      @tbl.push 0
      @max_bin_width = (@tbl.size - 1) / 2
    end

    alias old_dup dup
    def dup
      u = old_dup
      u.tbl = tbl.dup
      u
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
    end

    def adj_11
      changed = false
      (@zero - 1).downto(0) do |base|
        u = @tbl[base - 1]
        next if u.zero?
        # 1      :
        # 0      :- equals 4
        # 11     to_3 = 4
        i1 = 1
        j = 1
        while 0 < u
          if u & 3 == 3
            if (@tbl[base + 1] & i1).zero?
              @tbl[base + 1] |= i1
              @tbl[base - 1] ^= (j * 3)
              # take an extra step because 11 becomes 00
              i1 <<= 1
              j <<= 1
              u >>= 1
              changed = true
            else
              puts "found 11 but skipping #{base}"
            end
          end
          i1 <<= 1
          j <<= 1
          u >>= 1
        end
      end
      changed
    end

    def adj_101
      changed = false
      (@zero - 1).downto(0) do |base|
        u = @tbl[base - 1]
        # 1    :
        # 01   :- equals 10
        # 101  to_3 = 10
        i1 = 1
        i0 = 2
        j = 1
        while 0 < u
          if u & 5 == 5  # 101.to_3 = 10
            if (@tbl[base + 1] & i1).zero? &&
               (@tbl[base] & i0).zero?
              @tbl[base + 1] |= i1
              @tbl[base] |= i0
              @tbl[base - 1] ^= (j * 5)
              changed = true
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
      changed
    end

    def adj_1001
      (@zero - 1).downto(0) do |base|
        u = @tbl[base - 1]
        next if u.zero?
        # 1     :
        # 0110  :- equals 28
        # 1001  = 9.to_3 = 28
        i1 = 1
        i0 = 6
        j = 1
        while 0 < u
          if u & 9 == 9  # 101.to_3 = 10
            if (@tbl[base + 1] & i1).zero? &&
               (@tbl[base] & i0).zero?
              @tbl[base + 1] |= i1
              @tbl[base] |= i0
              @tbl[base - 1] ^= (j * 9)
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
    end

    def adj_10001
      (@zero - 1).downto(0) do |base|
        u = @tbl[base - 1]
        next if u.zero?
        # 1      :
        # 01110  :- equals 82
        # 10001  = 17.to_3 = 82
        i1 = 1
        i0 = 14
        j = 1
        while 0 < u
          if u & 17 == 17  # 101.to_3 = 10
            if (@tbl[base + 1] & i1).zero? &&
               (@tbl[base] & i0).zero?
              @tbl[base + 1] |= i1
              @tbl[base] |= i0
              @tbl[base - 1] ^= (j * 17)
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
      #adj_1
      while adj_11 || adj_101 do
      end

      adj_1001
      adj_10001
      self
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
      while 1 < n
        puts x.to_s if p
        x.iter
        nx = nx / 2 + (nx % 2)*(nx + 1)
        n = x.to_i
        raise "x.to_i = #{n}  nx = #{nx}" unless n == nx
        stats << [n, x.bits]
        if 0 < x.tbl[x.zero - 1]
          p = true
        end
      end
      stats
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
