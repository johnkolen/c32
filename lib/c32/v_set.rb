module C32
  class VSet
    attr_accessor :values
    attr_accessor :range

    def initialize *vals, **options
      @values = *vals.dup
      if options[:range]
        unless options[:range].is_a? Range
          raise "range is not a range: #{options[:range].inspect}"
        end
        @range = options[:range]
      else
        @values.sort!
        if @values.first
          x = @values.shift
          rmin = x
          rmax = x
          while !@values.empty? && rmin <= @values.first && @values.first <= rmax + 1
            rmax = @values.shift
          end
          @range = rmin..rmax
        else
          @range = nil
        end
      end
    end

    #def_delegators :@values, :size, :max, :each, :member?

    def size
      @range.size + @values.size
    end

    def max
      if @range
        if @values.empty?
          @range.max
        else
          [@range.max, @values.max].max
        end
      else
        @values.max
      end
    end

    def member? v
      @range.member?(v) || @values.member?(v)
    end

    def << v
      unless @range.member? v
        @values << v
      end
    end

    def map *args, &block
      rv = []
      @range.each{|x| rv << yield(x) }
      VSet.new *rv, *@values.map(*args, &block)
    end

    def each *args, &block
      if @range
        @range.each *args, &block
      end
      @values.each *args, &block
    end

    def union otr
      if @range.overlap? otr.range
        rmin = [@range.min, otr.range.min].min
        rmax = [@range.max, otr.range.max].max
        ary = []
        @values.union(otr.values).sort.each do |x|
          next if rmin <= x && x <= rmax
          if rmax + 1 == x
            rmax = x
            next
          end
          ary << x
        end
        VSet.new *ary, range: rmin..rmax
      else
        if @range.min < otr.range.min
          rmin = @range.min
          rmax = @range.max
          expand = otr.range.to_a
        else
          rmin = otr.range.min
          rmax = otr.range.max
          expand = @range.to_a
        end
        ary = []
        @values.union(otr.values, expand).sort.each do |x|
          next if rmin <= x && x <= rmax
          if rmax + 1 == x
            rmax = x
            next
          end
          ary << x
        end
        VSet.new *ary, range: rmin..rmax
      end
    end

    def to_a
      range.to_a.concat @values
    end

    def - otr
      rv = VSet.new(*(to_a - otr.to_a))
    end

    def inspect
      [@range, @values].inspect
    end
  end
end
