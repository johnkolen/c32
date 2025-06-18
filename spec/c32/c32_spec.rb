# frozen_string_literal: true

module C32
  RSpec.describe C32 do
    let(:seven) { C32.new 7 }
    let(:six) { C32.new 6 }

    context "initialization" do
      it { expect(C32.new 1).to be_a C32 }
      it { expect(seven.to_i).to eq 7 }
      it { expect(C32.new(0=>3, 1=>1).to_i).to eq 6 }
      it { expect(C32.new(bits: [9, 48, 64]).to_i).to eq 121 }
      it { expect(C32.new(minimal: 121).to_i).to eq 121 }
    end

    it "dup" do
      expect(seven.dup.tbl.object_id).not_to eq seven.tbl.object_id
    end

    context "math ops" do
      it { expect(seven.dup.mul3.to_i).to eq 21 }
      it { expect{seven.dup.add1.to_i}.to raise_error(String) }
      it { expect(six.dup.add1.to_i).to eq 7 }
      it { expect(six.dup.div2.to_i).to eq 3 }
      it { x = C32.new(3); x.mul3 ; expect(x.to_i).to eq 9
        x.add1; expect(x.to_i).to eq 10
        x.div2;  expect(x.to_i).to eq 5
      }
    end
    context "bit shuffling" do
      it "fill_left" do
        #x = C32.new(3); x.mul3; expect(x.to_i).to eq 9
        #x.add1; expect(x.to_i).to eq 10
        #x.tbl[x.zero] = 0; expect(x.to_i).to eq 6
        #x.fill_left(4, x.zero); expect(x.to_i).to eq 10
      end
      context "rotates" do
        it "clean" do
          x = C32.new -1=>5, 5=>2
          puts x.to_s
          expect(x.to_i).to eq 101
          x.rotate
          puts x.to_s
          expect(x.to_i).to eq 101
          expect(x.tbl[x.zero - 1]).to eq 0
        end
        it "occupied" do
          x = C32.new -1=>5, 2=>1
          puts x.to_s
          expect(x.to_i).to eq 9
          x.rotate
          puts x.to_s
          expect(x.to_i).to eq 9
        end
        it "occupied 2" do
          x = C32.new -1=>5, 0=>3
          puts x.to_s
          expect(x.to_i).to eq 9
          x.rotate
          puts x.to_s
          expect(x.to_i).to eq 9
        end
        it "collapses 4" do
          x = C32.new 0=>3
          puts x.to_s
          expect(x.to_i).to eq 4
          x.collapse
          puts x.to_s
          expect(x.to_i).to eq 4
        end
        it "collapses 4" do
          x = C32.new 0=>2**4-1
          puts x.to_s
          expect(x.to_i).to eq 40
          x.collapse
          puts x.to_s
          expect(x.to_i).to eq 40
        end
        it "collapses 6" do
          skip
          x = C32.new 0=>2**6-1
          puts x.to_s
          expect(x.to_i).to eq 364
          x.collapse
          puts x.to_s
          expect(x.to_i).to eq 364
        end
      end
    end

    context "collatz" do
      it "by parts" do
        n = 31
        x = C32.new n
        max_iter = 9999
        while x.to_i != 1
          break if max_iter == 0
          max_iter -= 1
          puts "  #{x.to_i}  #{n}"
          puts x.to_s
          puts "=" * 10
          x.iter
          if n.to_i % 2 == 1
            n = (3 * n + 1) / 2
          else
            n >>= 1
          end
          expect(x.to_i).to eq n
        end
        puts "  #{x.to_i}  #{n}"
        puts x.to_s
      end

      it "collatz class 7" do
        stats, c = C32.collatz 7
        puts stats.inspect
      end
      it "collatz class 31" do
        5.upto(1024) do |n|
          C32.minimal_bits n
        end
        stats, c = C32.collatz 31
        puts stats.inspect
        puts c.tbl.size - c.zero
        puts c.to_s
      end
      it "longest" do
        [7, 15, 31, 63, 111, 255, 511, 703, 2047, 4095].each do |n|
          puts "start #{n}"
          stats, c = C32.collatz n
          bits = c.tbl.size - c.zero
          puts "#{n} #{(Math.log2(n)+0.999).to_i} #{bits}"
        end
      end
    end

    context "get at" do
      let(:c) { C32.new 0=>7, 2=>3, 5=>1 }
      it { expect(c.get_at 0, 0).to eq 1}
      it { expect(c.get_at 0, 1).to eq 1}
      it { expect(c.get_at 0, 2).to eq 1}
      it { expect(c.get_at 0, 3).to eq 0}
      it { expect(c.get_at 6, 0).to eq 0}
    end

    context "set at" do
      let(:c) { C32.new 0=>7, 2=>3, 5=>1 }
      it { c.set_at(0, 3, 1); expect(c.get_at 0, 3).to eq 1}
      it { c.set_at(0, 3, 0); expect(c.get_at 0, 3).to eq 0}
    end

    context "fill" do
      it "triangle" do
        z = C32.new(27 << 3)
        puts z.to_s
        z.fill_triangle
        puts z.to_s
        puts z.to_i
      end
      it "trapezoid" do
        z = C32.new(27 << 3)
        puts z.to_s
        z.fill_trapezoid
        puts z.to_s
        puts z.to_i
      end
      it "square" do
        z = C32.new(63)
        puts z.to_s
        z.fill_square
        puts z.to_s
        puts z.to_i
      end
      it "circle" do
        z = C32.new(31) # 31 << 3)
        puts z.to_s
        z.fill_circle
        puts z.to_s
        puts z.to_i
      end
      it "ridge" do
        z = C32.new(27 << 3)
        puts z.to_s
        z.fill_ridge
        puts z.to_s
        puts z.to_i.to_i
      end
    end
    context "footprint" do
      it "|= smaller" do
        a = C32.new(7).mul3
        b = C32.new(11)
        b.or_eq  a
        expect(b.to_i).to eq 32
      end
      it "|= larger" do
        a = C32.new(20).mul3
        expect(a.to_i).to eq 60
        b = C32.new(11)
        b.or_eq  a
        expect(b.to_i).to eq 71
      end
    end

    it "works" do
      3.upto(35) do |n|
        c = 3**n
        b = 2**(n+1) - 1
        i = 0
        while b < c
          c -= b
          c = c / 3
          # b >>= 1
          i+= 1
        end
        puts "%2d %2d" % [n , i]
      end
    end
    it "calcs" do
      n = 2**5 - 1
      1.upto n do |x|
        x3 = x.from_3
        puts "#{x}  #{x.to_s(2).reverse} :  #{x3}" if 2 * n < x3
      end
    end

    context "crinkle" do
      it "width 18" do
        c = C32.new 2**18 - 1
        tgt = 3486784401
        r = c.crinkle tgt
        puts r.inspect
        expect(r.reverse.inject(0){|sum, x| 3 * sum + x }).to eq tgt
      end

      it "3^5 width 5 with one" do
        c = C32.new 2**5 - 1
        tgt = 3**5
        r = c.crinkle tgt
        expect(r.reverse.inject(0){|sum, x| 3 * sum + x }).to eq tgt
        expect(r.map(&:size2).max).to be <= 5 + 1
      end
      it "many with one" do
        3.upto(100) do |i|
          c = C32.new 2**i - 1
          tgt = 3**i
          r = c.crinkle tgt
          expect(r.reverse.inject(0){|sum, x| 3 * sum + x }).to eq tgt
          expect(r.map(&:size2).max).to be <= i + 1
        end
      end
      it "3^5 width 5 with two" do
        c = C32.new 2**5 - 1
        tgt = (1 + 2) * 3**5
        r = c.crinkle tgt
        expect(r.reverse.inject(0){|sum, x| 3 * sum + x }).to eq tgt
      end
      it "many with two" do
        3.upto(100) do |i|
          c = C32.new 2**i - 1
          tgt = (1 + 2) * 3**i
          r = c.crinkle tgt
          expect(r.reverse.inject(0){|sum, x| 3 * sum + x }).to eq tgt
          expect(r.map(&:size2).max).to be <= i + 1
        end
      end
    end
    it "rotate b" do
      n = 8
      c = C32.new 2**(n-1)
      c.set_at n - 1, 0, 0
      c.set_at -1, n, 1
      c.set_at -1, n - 1, 1
      c.set_at -1, n - 2, 1
      c.set_at -1, 0, 1
      v = c.to_i
      puts c.fixed_width
      puts c.to_s
      c.rotate_b v
      puts c.to_s
    end

    context "row col sums" do
      let(:c) { C32.new 0=>7, 2=>3 }
      it {expect(c.row_sum(0)).to eq 13}
      it {expect(c.row_sum(1)).to eq 0}
      it {expect(c.row_sum(2)).to eq 4}
      it {expect(c.col_sum(0)).to eq 5}
      it {expect(c.col_sum(1)).to eq 5}
      it {expect(c.col_sum(2)).to eq 1}
      it {expect(c.col_sum(3)).to eq 0}
    end
    context "find value" do
      let(:c) { C32.new 0=>7, 2=>3 }
      let(:ary) {[[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0],
                  [6, 0], [5, 1], [4, 2], [3, 3], [2, 4]]}
      it { expect(c.find_value 4, ary).to eq [[2, 0]] }
      it { expect(c.find_value 3, ary).to eq [[0, 0], [1, 0]] }
      it { expect(c.find_value 32*3, ary).to eq [[5, 1]] }
    end

    context "minimal" do
      it "works" do
        expect(C32.minimal_bits 31).to eq [4, 27]
        r = [C32.calls]
        expect(C32.minimal_bits 5.ps3).to eq [9, 48, 64]
        r << C32.calls
        puts r.inspect
        expect(C32.minimal_bits 4616).to eq [8, 4608]
      end
    end
    context "paper" do
      it "representations of 127" do
        v = 127
        puts v
        c = C32.new v
        puts c.to_s
        c = C32.new minimal: v
        puts "==="
        puts c.to_s
        v3 = v.to_3
        c = C32.new 0=> v3.first, 1=>v3.last
        puts "==="
        puts c.to_s
      end
      it "oscilation" do
        c = C32.new 2
        puts c.to_s
        4.times do
          puts "==="
          c.iter
          puts c.to_s
        end
      end
    end
    context "playground" do
      it "min" do
        i = 9
        5.times do |j|
          bits = C32.minimal_bits (1 + i) / 2
          puts "#{j} #{((i+1)/2).to_s(3).reverse} #{bits.inspect} : #{i}"
          i *= 3
        end
      end

      it "replace" do
        n = 8
        c = C32.new 0=>2**n
        puts c.to_s
        v = c.to_i
        c.replace 0, n
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
        c.replace 1, n - 1
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
        c.replace 1, n - 2
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
        c.replace 2, n - 2
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
        c.replace 4, n - 3
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
        c.replace 5, n - 4
        puts "=" * 10
        puts c.to_s
        expect(c.to_i).to eq v
      end
      context "replace triangle" do
      it "replaca" do
        i = 0
        n = 8
        c = C32.new 2**(n-1)
        puts c.fixed_width
        c.set_at n-1, 0, 0
        c.set_at i, n, 1
        puts c.to_s
        puts c.to_i
        puts "===="
        c.replace_tri i,n
        puts c.to_s
        puts c.to_i
        puts "max i+j = #{c.max_ij}"
      end
      it "replaca 2" do
        i = 1
        n = 8
        c = C32.new 2**(n-1)
        puts c.fixed_width
        c.set_at n-1, 0, 0
        c.set_at i, n, 1
        puts c.to_s
        puts c.to_i
        puts "===="
        c.replace_tri i,n
        puts c.to_s
        puts c.to_i
        puts "max i+j = #{c.max_ij}"
      end
      it "replaca 1 and 2" do
        i = 1
        n = 8
        c = C32.new 2**(n-1)
        puts c.fixed_width
        c.set_at n-1, 0, 0
        c.set_at i, n, 1
        c.set_at i - 1, n, 1
        puts c.to_s
        puts c.to_i
        puts "===="
        c.replace_tri i,n
        c.replace_tri i - 1,n
        puts c.to_s
        puts c.to_i
        puts "max i+j = #{c.max_ij}"
      end
      it "replaca 4" do
        i = 2
        n = 8
        c = C32.new 2**(n-1)
        puts c.fixed_width
        c.set_at n-1, 0, 0
        c.set_at i, n, 1
        puts c.to_s
        puts c.to_i
        puts "===="
        c.replace_tri i,n
        puts c.to_s
        puts c.to_i
        puts "max i+j = #{c.max_ij}"
      end
      end
    end
  end
end
