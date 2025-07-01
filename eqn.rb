#!/usr/bin/env ruby
require_relative "lib/c32"

class Bag < Array
  def to_s
    s = map(&:to_s).join(", ")
    "[#{s}]"
  end

  def iter
    sum = 0
    each{|x| sum += 1 if x.odd?}
    if sum.odd?
      mul3.add1!.div2
    else
      div2
    end
  end

  def to_i
    inject(0){|s, x| s + x.to_i}
  end

  def mul3
    Bag.new map(&:mul3)
  end

  def div2
    rsum = 0
    tsum = []
    each do |t|
      x = t.div2
      if x.is_a? Rational
        rsum += x
      else
        tsum << x
      end
    end
    Bag.new tsum.concat Term.twos(rsum.to_i)
  end

  def add1!
    j = 0
    t = Term.get(j, 0)
    while member? t
      delete t
      j += 1
      t = Term.get(j, 0)
    end
    push t
    self
  end
end

class Term
  def initialize i, j
    raise "bad i: #{i}, #{j}" if i < 0
    raise "bad j: #{i}, #{j}" if j < 0
    @i = i
    @j = j
  end

  def to_i
    @ival ||= 2**@i * 3**@j
  end

  def odd?
    @i == 0
  end

  def == otr
    to_i == otr.to_i
  end

  def eql? otr
    to_i == otr.to_i
  end

  def hash
    to_i.hash
  end

  def mul3
    self.class.get @i, @j + 1
  end

  def div2
    return Rational(3**@j, 2) if @i == 0
    self.class.get @i - 1, @j
  end

  def seq
    @seq ||= _seq_c
  end

  def prev
    if @j == 0
      if @i == 0
        return nil
      else
        Term.get(0, @i - 1)
      end
    else
      Term.get(@i + 1, @j - 1)
    end
  end

  def next
    if @i == 0
      if @j == 0
        return nil
      else
        Term.get(@j + 1, 0)
      end
    else
      Term.get(@i - 1, @j + 1)
    end
  end

  def _seq_c
    ij = @i + @j
    return 0 if ij == 0
    (ij + 1) * ij / 2 + @j
  end

  def to_s
    "<#{@i},#{@j}>"
  end

  def self.get i, j
    @terms ||= Hash.new{|h, k| h[k] = Term.new k[0], k[1]}
    t = @terms[[i, j]]
    @seq2terms ||= {}
    @seq2terms[t.seq] = t
    t
  end

  def self.twos x
    res = []
    i = 0
    while 0 < x
      x, m = x.divmod 2
      res << Term.get(i, 0) if m == 1
      i += 1
    end
    Bag.new res
  end

  def self.terms
    @terms.values
  end

  def self.threes x
    res = Bag.new
    j = 0
    while 0 < x
      x, m = x.divmod 3
      res << Term.get(m - 1, j) unless m.zero?
      j += 1
    end
    res
  end

  LOG_3 = Math.log(3)
  def self.minimal x
    list = [Term.get(x.size2, 0)]
    while list.first.to_i < x
      list.unshift list.first.next
    end
    list.shift if 1 < list.size
    while list.last
      list.push list.last.prev
    end
    while x < list.first.to_i
      list.shift
    end
    #puts list.inspect
    list.pop
    @sums = list.reverse!.inject([[0,nil]])do |list, t|
      sum, tx = list.last
      list.push [sum + t.to_i, t]
      list
    end
    # puts @sums.inspect
    Bag.new minimal_rec(x, @sums.size - 1)
  end

  def self.minimal_rec x, idx
    #puts "rec #{x}, #{idx}"
    @mr_memo ||= {}
    return [] if x == 0
    memo = @mr_memo[[x,idx]]
    return memo.dup if memo
    csum, cterm = @sums[idx]
    return nil if csum < x
    if csum == x
      return @sums[1..idx].map(&:last)
    end
    cidx = idx
    while x < cterm.to_i
      idx -= 1
      csum, cterm = @sums[idx]
    end
    return [cterm] if cterm.to_i == x
    # skip the current
    s1 = minimal_rec x, idx - 1
    s1_size = s1 ? s1.size : 999999
    # take the current
    s2 = nil
    if cterm.to_i < x
      s2 = minimal_rec x - cterm.to_i, idx - 1
    end
    s2_size = s2 ? s2.size + 1 : 999999
    if s1_size <= s2_size
      @mr_memo[[x, cidx]] = s1 if s1
      s1
    else
      @mr_memo[[x, cidx]] = s2.dup.push cterm
    end
  end
end

class Matrix < Array
  LOG_10 = Math.log(10)
  attr_accessor :aug

  def initialize *args, **options
    super *args
    @aug = options[:aug] || 0 # augmented colum
    @row_size = options[:row_size] || (first || []).size
  end

  def max_abs
    m = 0
    each do |row|
      row.each do |x|
        case x
        when Integer
          x = x.abs
          m = x if m < x
        else
          x.each do |x|
            x = x.abs
            m = x if m < x
          end
        end
      end
    end
    m
  end

  def to_s
    out = []
    w = (Math.log(max_abs) / LOG_10+0.0001).ceil
    fmt = "%#{w + 1}d "
    each do |row|
      rx = []
      row.each_with_index do |x, idx|
        if idx == @aug && 0 < @aug
          rx.push ": "
        end
        if x.is_a? Integer
          rx.push fmt % x
        else
          x.each do |x|
            rx.push fmt % x
          end
        end
        if idx == @aug && @aug.zero?
          rx.push ": "
        end
      end
      out.push rx.join
    end
    out.join("\n")
  end

  def align!
    #raise "aug is not zero" unless @aug.zero?
    @row_size = [map(&:size).max, @row_size].max
    mi = @row_size - 1
    each_with_index do |row, idx|
      if row[mi].nil?
        row[mi] = 0
        row = row.map{|x| x || 0}
        self[idx] = row
      end
      # aug is now last
      if @aug == 0
        row.push row.shift
      end
    end
    @aug = mi if @aug == 0
    self
  end

  def add_row add, sub, v
    raise "aug is not zero"  unless @aug.zero?
    row = [v]
    add.each do |t|
      row[t.seq + 1] = 1
    end
    sub.each do |t|
      idx = t.seq + 1
      if row[idx] == 1
        row[idx] = 0
      else
        row[idx] = -1
      end
    end
    row = row.map{|x| x || 0}
    self.push row
    self
  end

  def remove_gcd row=nil
    unless row
      each_with_index do |row, idx|
        self[idx] = remove_gcd row
      end
      return
    end
    nz = row.select{|x| !x.zero? }
    return row if nz.empty?
    c = nz.inject(nz.max){|g, x| g.gcd x}
    row.map{|x| x / c}
  end

  def row_zero? row
    row.all?(&:zero?)
  end

  def row_nonnegative? row
    row.all?{|x| x.zero? || x.positive?}
  end
  def row_nonpositive? row
    row.all?{|x| x.zero? || x.negative?}
  end

  def row_active row
    rv = []
    row.each_with_index{|x, j| rv << j if x.nonzero?}
    rv
  end

  def summary_eq
    res = []
    make_labels unless @labels
    each do |row|
      lhs = []
      rhs = []
      z = row.pop
      rhs << z unless z.zero?
      row.each_with_index do |x, i|
        next if x.zero?
        sym = i < @aug ? "x[#{i}]" : "e[#{i - @aug}]"
        sym = @labels[i] if @labels
        if 0 < x && sym[0] == "x" || (x < 0 && sym[0] == "x" && lhs.empty?)
          if x == 1
            lhs << sym
          else
            lhs << "#{x}*#{sym}"
          end
        else
          if x == -1
            rhs << sym
          else
            rhs << "#{-x}*#{sym}"
          end
        end
      end
      row.push z
      if 1 < lhs.size
        rx = []
        lhs.each do |x|
          if x[0] == '-'
            rhs.unshift x.sub('-', '').sub(/^1\*/, '')
            rx << x
          end
        end
        rx.each{|x| lhs.delete(x)}
      elsif lhs.size == 1
        x = lhs.first
        if x[0] == '-' && rhs.size == 1 && rhs[0].is_a?(Integer)
          x.sub!("-", "")
          x.sub!(/^1\*/, "")
          rhs[0] *= -1
        end
      end
      rhs << 0 if rhs.empty?
      lhs << 0 if lhs.empty?
      res << "#{lhs.join(' + ')} == #{rhs.join(' + ')}"
    end
    res.join("; ")
  end

  def flatten_rows!
    each{|row| row.flatten!}
    align!
    self
  end
  def summary_ge
    res = []
    each do |row|
      lhs = []
      rhs = []
      z = row.pop
      rhs << z unless z.zero?
      row.each_with_index do |x, i|
        next if x.zero?
        sym = i < @aug ? "x[#{i}]" : "e[#{i - @aug}]"
        if 0 < x
          if x == 1
            lhs << sym
          else
            lhs << "#{x}*#{sym}"
          end
        else
          if x == -1
            rhs << sym
          else
            rhs << "#{-x}*#{sym}"
          end
        end
      end
      row.push z
      rhs << 0 if rhs.empty?
      lhs << 0 if lhs.empty?
      res << "#{lhs.join(' + ')} >= #{rhs.join(' + ')}"
    end
    res.join("; ")
  end

  def solve_eq
    m = gaussian_elim
    m.gaussian_rev
  end

  def gaussian_rev pivot=nil
    if pivot.nil?
      return gaussian_rev size - 1
    end
    return self if pivot < 1
    prow = self[pivot]
    pcol = pivot
    px = prow[pcol]
    while px.zero?
      pcol += 1
      px = prow[pcol]
    end
    (0...pivot).each do |i|
      row = self[i]
      rx = row[pcol]
      unless rx.zero?
        row.each_with_index do |x, j|
          row[j] = px * x - rx * prow[j]
        end
        self[i] = remove_gcd row
      end
    end
    gaussian_rev pivot - 1
  end

  def gaussian_elim fr=nil, col=nil
    if col.nil?
      align! if @aug.zero?
      rv = self
      fr = 0
      0.upto(first.size - 1) do |c| #
        fr, rv = rv.gaussian_elim(fr, c)
      end
      return rv
    end

    finished = []
    zero = []
    todo = []
    each_with_index do |row, idx|
      if idx < fr
        finished.push row
      elsif row[col].zero?
        zero.push row unless row_zero?(row)
      else
        todo.push row
      end
    end

    unless todo.empty?
      todo.sort!
      finished.push remove_gcd(todo.shift)
      fr += 1
      qrow = finished.last
      q = qrow[col]
      mi = first.size - 1
      while !todo.empty?
        row = todo.pop
        x = row[col]
        #puts qrow.inspect
        #puts row.inspect
        col.upto(mi) do |i|
          row[i] = q * row[i] - x * qrow[i]
        end
        #puts row.inspect
        #puts "--"
        unless row_zero? row
          finished.push remove_gcd(row)
        end
      end
    end
    finished.concat zero
    [fr, Matrix.new(finished, aug: @aug)]
  end

  def zero_column j
    each do |row|
      row[j] = 0
    end
  end

  attr_accessor :labels
  def make_labels
    @labels = []
    @aug.times do |i|
      @labels << "x[#{i}]"
    end
    (@aug...first.size).each do |i|
      @labels << "e[#{i - @aug}]"
    end
    @labels.pop
    @labels.push "1"
  end

  def remove_zero_cols
    s = [true] * first.size
    each do |row|
      row.each_with_index do |x, i|
        s[i] &= x.zero?
      end
    end
    remove = []
    s.each_with_index do |x, i|
      remove << i if x
    end
    remove.pop if remove.last == first.size - 1
    remove.reverse!
    each do |row|
      remove.each{|i| row.delete_at i}
    end
    if @labels
      remove.each{|i| @labels.delete_at i}
    end
    remove.each do |i|
      @aug -= 1 if i < @aug
    end
  end

  def slack_assignments
    assignments = {}
    make_labels unless @labels
    remove_zero_cols
    u = 0
    outer = true
    while outer
      outer = false
      changed = true
      while changed
        changed = false
        remove = []
        each_with_index do |row, idx|
          if row_zero? row[0...@aug]
            puts row.inspect
            rest = row[@aug...row.size]
            puts rest.inspect
            if row_nonnegative?(rest) || row_nonpositive?(rest)
              remove << idx
              changed = true
              rest.each_with_index do |x, j|
                if x.nonzero?
                  v = @labels[j + @aug]
                  puts "#{v} == 0"
                  assignments[v] = "0"
                  zero_column @aug + j
                end
              end
            else
              active = row_active(rest)
              if active.size == 2
                changed = true
                active[0] += @aug
                active[1] += @aug
                v0 = @labels[active[0]]
                v1 = @labels[active[1]]
                puts "#{v0} == #{v1}"
                assignments[v0] = v1
                c0 = row[active[0]]
                c1 = row[active[1]]
                each do |rx|
                  rx[active[0]] = rx[active[0]] * c1 + rx[active[1]] * c0
                  rx[active[1]] = 0
                end
              end
            end
          end
        end
        remove.reverse.each do |idx|
          raise "wtf" unless row_zero? self[idx]
          delete_at idx
        end
        if changed
          remove_zero_cols
        end
        #(0...size).reverse.each do |idx|
        #p  if row_zero?
      end
      remove_gcd
      if @aug + 1 < first.size
        j = first.size - 2
        u += 1
        v = @labels[j]
        puts "#{v} == #{u}"
        assignments[v] = u.to_s
        ones = first.size - 1
        each do |rx|
          rx[ones] += rx[j] * u
          rx[j] = 0
        end
        remove_zero_cols
        outer = true
      end
    end
    assignments
  end
end

#z = Term.minimal(28)
#puts z.to_s
#puts z.to_i
#exit
def time msg = nil, &block
  start = Time.now
  yield
  elapsed = Time.now - start
  if msg
    puts msg % elapsed
  else
    puts elapsed
  end
end

n = (ARGV[0] || 3).to_i


matrix = Matrix.new

# Both 1 and 2 have the same representation for bases two and three
puts "Finding equivalences"
3.upto(2**n-1) do |i|
  #puts "#{i.to_s(2)} = #{i.to_s(3)}"
  twos = Term.twos(i)
  threes = Term.threes(i)
  #puts "   #{twos} == #{threes}"
  matrix.add_row twos, threes, 0
  #puts matrix.last.inspect
end
puts "terms in use: #{Bag.new(Term.terms)}"

puts "Found #{matrix.size} equivalences"
puts "Solving equivalences..."
matrix_soln = nil
time "solved in %8.2f seconds" do
  matrix_soln = matrix.align!.solve_eq
end
puts matrix_soln.to_s if matrix_soln.size < 10
puts matrix_soln.summary_eq
puts "====" * 10

def c n
  if n.odd?
    3 * (n >> 1) + 2
  else
    n >> 1
  end
end

def iter n, min=1, &block
  while true
    yield n if block_given?
    n = c(n)
    break if n <= min
  end
  yield n
end

puts "\nTransitions"
trans = Set.new
3.upto(2**n-1) do |i|
  #print "#{i}: "
  prev = i
  i = c(i)
  iter i, prev do |x|
    #print "[#{prev}, #{x}] "
    trans.add [prev, x]
    prev = x
  end
  #puts
end
#puts trans.inspect
puts "Found #{trans.size} transitions"

tmatrix = Matrix.new
e = [1, 0]
puts "Finding transitions"
trans.each do |u, v|
  #puts "#{u} -> #{v}"
  if true
    u2 = Term.twos(u)
    u2n = u2.iter
    #puts "  #{u2} => #{u2n}"
    raise "bad u2 trans #{u2n.to_i} != #{v}" unless u2n.to_i == v
    tmatrix.add_row u2, u2n, e
  end
  if true
    u3 = Term.threes(u)
    u3n = u2.iter
    #puts "  #{u3} => #{u3n}"
    raise "bad u3 trans #{u3n.to_i} != #{v}" unless u3n.to_i == v
    tmatrix.add_row u3, u3n, e
  end
  if true
    um = Term.minimal(u)
    umn = um.iter
    #puts "  #{um} => #{umn}"
    raise "bad um trans #{umn.to_i} != #{v}" unless umn.to_i == v
    tmatrix.add_row um, umn, e
  end
  e = ([0]*e.size).push 1
  e.push 0
end
puts "Solving transition matrix..."
tmatrix_soln = nil
time "solved in %8.2f seconds" do
  tmatrix_soln = tmatrix.align!.flatten_rows!.solve_eq
end
puts tmatrix_soln.to_s if tmatrix_soln.size < 15

puts "=" * 50
puts matrix_soln.summary_eq if matrix_soln.size < 10
puts tmatrix_soln.summary_eq if tmatrix_soln.size < 15
puts "=" * 50
all = tmatrix_soln.summary_eq.split("; ")
all.each do |eqn|
  puts eqn if eqn.index("x")
end
a = tmatrix_soln.slack_assignments
puts tmatrix_soln.labels.inspect
puts tmatrix_soln.to_s
puts a.inspect
tmatrix_soln.summary_eq.split("; ").each do |eqn|
  puts eqn
end

############################################
exit

all = matrix_soln.summary_eq.split("; ")
all.concat tmatrix_soln.summary_eq.split("; ")
all.each do |eqn|
  puts eqn if eqn.index("x")
end
puts "*" * 50
tmatrix_soln.concat matrix_soln
puts tmatrix_soln.to_s
tmatrix_soln.align!
puts tmatrix_soln.to_s
final = tmatrix_soln.solve_eq
puts "$" * 50
puts final.to_s
final.summary_eq.split("; ") do |eqn|
  puts eqn
end
a = final.slack_assignments
puts final.to_s
puts final.labels.inspect
puts a.inspect
final.summary_eq.split("; ") do |eqn|
  puts eqn
end

@fact = [1, 1]
def fact n
  fx = @fact[n]
  return fx unless fx.nil?
  @fact[n] = n * fact(n - 1)
end
def choose n, m
  fact(n) / fact(m) / fact(n - m)
end
sum = 0
k = 0
tgt = 2**n - 1 - 2  # eliminate one and two
n.times do
  sum += choose(n, k)
  k += 1
  break if tgt < sum
end
puts "rows = #{tgt} sum = #{sum}  k = #{k}"

puts "*" * 40
puts tmatrix.to_s
puts "aug = #{tmatrix.aug}"
puts "----" * 5
puts tmatrix.align!.to_s
puts "first align aug = #{tmatrix.aug}"
puts "----" * 5
tmatrix.each{|row| row.flatten!}
puts tmatrix.align!.to_s
puts "aug = #{tmatrix.aug}"
puts "----" * 5
tm0 = tmatrix.gaussian_elim
puts tm0.to_s
puts "aug = #{tm0.aug}"
puts "----" * 5
tr0 = tm0.gaussian_rev
puts tr0.to_s
puts "aug = #{tr0.aug}"
