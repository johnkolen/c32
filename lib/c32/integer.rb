# frozen_string_literal: true

class Integer
  def bits
    x = self
    c = 0
    while 0 < x
      c += x & 1
      x >>= 1
    end
    c
  end

  def from_3
    x = self
    c = 0
    t = 1
    while 0 < x
      c += (x & 1) * t
      x >>= 1
      t *= 3
    end
    c
  end

  def to_3
    x = self
    v1 = 0
    v2 = 0
    t = 1
    while 0 < x
      c = x % 3
      if c == 2
        v2 += t
      elsif c == 1
        v1 += t
      end
      x = x / 3
      t <<= 1
    end
    [v1, v2]
  end

  def ps3
    n = self
    v = 1
    n -= 1
    while 0 < n
      n -= 1
      v = 3 * v + 1
    end
    v
  end

  # in:  100001000100000001
  # out: 1000000001
  #      11111000011111111
  def div32
    a = 0
    b = 0
    t = 1
    s = false
    z = self
    while 0 < z
      if z & 1 == 1
        if s
          s = false
        else
          a |= t
          b |= t
          s = true
        end
      else
        b |= t if s
      end
      t <<= 1
      z >>= 1
    end
    [a, b]
  end

end
