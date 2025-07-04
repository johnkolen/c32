module C32
  class ModX
    def initialize x
      @x = x
    end
    def table n
      puts "x = #{@x}"
      0.upto(n) do |i|
        vx = []
        (0...n).each_with_index do |j, idx|
          vx << ("%4d " % ((2**i * 3**j) % @x))
        end
        puts "%2d: %4d :: #{vx.join}" % [i, 2**i % @x]
      end
    end
  end
end
