# frozen_string_literal: true

module C32
  RSpec.describe C32 do
    let(:seven) { C32.new 7 }
    let(:six) { C32.new 6 }

    context "initialization" do
      it { expect(C32.new 1).to be_a C32 }
      it { expect(seven.to_i).to eq 7 }
      it { expect(C32.new(0=>3, 1=>1).to_i).to eq 6 }
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
      context "adj_11" do
        it "works" do
          x = C32.new 0=>3
          expect(x.to_i).to eq 4
          x.div2
          expect(x.to_i).to eq 2
          x.adj_11
          expect(x.to_i).to eq 2
          expect(x.tbl[x.zero - 1]).to eq 0
        end
        it "skips" do
          x = C32.new 0=>3, 2=>1
          expect(x.to_i).to eq 8
          x.div2
          expect(x.to_i).to eq 4
          x.adj_11
          expect(x.to_i).to eq 4
          expect(x.tbl[x.zero - 1]).to eq 3
        end
      end
      context "adj_101" do
        it "works" do
          x = C32.new 0=>5
          expect(x.to_i).to eq 10
          x.div2
          expect(x.to_i).to eq 5
          x.adj_101
          expect(x.to_i).to eq 5
          expect(x.tbl[x.zero - 1]).to eq 0
        end
        it "skips" do
          x = C32.new 0=>5, 1=>2, 2=>1
          expect(x.to_i).to eq 20
          x.div2
          expect(x.to_i).to eq 10
          x.adj_101
          expect(x.to_i).to eq 10
          expect(x.tbl[x.zero - 1]).to eq 5
        end
      end

      context "adj_1001" do
        it "works" do
          x = C32.new 0=>9
          expect(x.to_i).to eq 28
          x.div2
          expect(x.to_i).to eq 14
          x.adj_1001
          expect(x.to_i).to eq 14
          expect(x.tbl[x.zero - 1]).to eq 0
        end
        it "skips" do
          x = C32.new 0=>9, 1=>6, 2=>1
          expect(x.to_i).to eq 56
          x.div2
          expect(x.to_i).to eq 28
          x.adj_1001
          expect(x.to_i).to eq 28
          expect(x.tbl[x.zero - 1]).to eq 9
        end
      end

      context "adj_10001" do
        it "works" do
          x = C32.new 0=>17
          expect(x.to_i).to eq 82
          x.div2
          expect(x.to_i).to eq 41
          x.adj_10001
          expect(x.to_i).to eq 41
          expect(x.tbl[x.zero - 1]).to eq 0
        end
        it "skips" do
          x = C32.new 0=>17, 1=>14, 2=>1
          expect(x.to_i).to eq 164
          x.div2
          expect(x.to_i).to eq 82
          x.adj_10001
          expect(x.to_i).to eq 82
          expect(x.tbl[x.zero - 1]).to eq 17
        end
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
        stats, c = C32.collatz 31
        puts stats.inspect
        puts c.tbl.size - c.zero
        puts c.to_s
      end
      it "longest" do
        [7, 15, 31, 63, 111,255, 511, 703, 2047, 4095].each do |n|
          stats, c = C32.collatz n
          bits = c.tbl.size - c.zero
          puts "#{n} #{(Math.log2(n)+0.999).to_i} #{bits}"
        end
      end
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
        x3 = x.to_3
        puts "#{x}  #{x.to_s(2).reverse} :  #{x3}" if 2 * n < x3
      end
    end
  end
end
