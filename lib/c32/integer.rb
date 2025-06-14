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

  def to_3
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
end
