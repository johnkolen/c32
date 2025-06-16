# frozen_string_literal: true

module C32
  class Area
    def initialize n=3, m=nil
      m ||= n
      @rows = Array.new(n) { ['.'] * m }
    end

    def size_r
      @rows.size
    end

    def size_c
      @rows.map(&:size).max
    end

    def to_s
      @rows.reverse.
        map{|x| x.map{|y| y || '*'}.join}.
        join("\n")
    end

    def add_top n
      n.times do
        @rows.push ['*']
      end
    end

    def add_side row, n
      row.concat ['*'] * n
    end

    def at i, j
      add_top i - @rows.size + 1 if @rows.size <= i
      r = @rows[i]
      add_side r, j - r.size + 1 if r.size <= j
      r[j]
    end

    def set_at i, j, v
      add_top i - @rows.size + 1 if @rows.size <= i
      r = @rows[i]
      add_side r, j - r.size + 1 if r.size <= j
      r[j] = v
    end

    def set_diagonal_at i, j, v
      while 0 <= i
        set_at i, j, v
        i -= 1
        j += 1
      end
    end
  end
end
