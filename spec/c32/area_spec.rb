# frozen_string_literal: true

module C32
  RSpec.describe Area do
    let(:a) { Area.new 3 }
    let(:a3x4) { Area.new 3, 4 }
    it { expect(a).to be_a Area }
    it { expect(a.to_s).to eq "...\n...\n..." }
    it { expect(a3x4.size_r).to eq 3 }
    it { expect(a3x4.size_c).to eq 4 }
    it "sets at" do
      a.set_at 1, 2, 'a'
      expect(a.at 1, 2).to eq 'a'
    end
    context "sets diagonal" do
      it "within" do
        a.set_diagonal_at 2, 0, 'a'
        expect(a.at 2, 0).to eq 'a'
        expect(a.at 0, 2).to eq 'a'
        expect(a.to_s).to eq "a..\n.a.\n..a"
      end
      it "outside 1" do
        a.set_diagonal_at 3, 0, 'a'
        expect(a.at 3, 0).to eq 'a'
        expect(a.at 0, 3).to eq 'a'
        #a.set_at 2, 0, 'a'
        expect(a.to_s).to eq "a\n.a.\n..a\n...a"
      end
      it "outside 2" do
        a.set_diagonal_at 4, 0, 'a'
        #a.set_at 2, 0, 'a'
        expect(a.to_s).to eq "a\n*a\n..a\n...a\n...*a"
      end
    end
    it "experiment" do
      n = 5 # bits
      bmax = 2**n - 1
      a = Area.new n
      a.set_diagonal_at n - 1, 0, 'a'
      puts a.to_s
      u = (3**n - 1) / 2
      puts "1#{u.to_s(3)}"
      u2 = u / 3**(bmax.size3 - 1)
      puts "a" * bmax.size3 + "b" * u2.size3
      a.set_diagonal_at u2 .size3, bmax.size3, 'b'
      puts a.to_s
      a.set_at 1, n, 'c'
      a.set_at 0, n, 'c'
      puts "=" * 3
      puts a.to_s
      puts "a" * bmax.size3 + "b" * u2.size3
      c = 3**n + 2*3**n
      puts c
      puts c.to_s(3).reverse
      puts c.to_s(2).reverse
      puts c.to_s(4).reverse
      cx = c
      nx = n
      j = 0
      while 0 < cx
        if cx < 2**nx
          a.set_diagonal_at cx.size2, j, 'c'
          break
        end
        a.set_diagonal_at nx + 1, j, 'c'
        cx -= 2**nx - 1
        cx = cx / 3
        nx -= 1
        j += 1
      end
      puts "=" * 3
      puts a.to_s
    end

    it "paper" do
      n = 8
      n2 = 2**8 - 1
      puts n2
      a = Area.new n
      a.set_diagonal_at n - 1, 0, 'a'
      puts a.to_s
      amax = 1
      abits = 1
      while amax * 3 < n2
        amax *= 3
        abits += 1
      end
      puts "-" * 8
      puts "a" * abits
      puts "amax = #{amax}"
      puts "====="
      bbits = n - abits + 1
      a.set_diagonal_at n - 1, 0, '.'
      ahx = (1..n).to_a.reverse
      bmax = (2**bbits - 1)
      puts "bmax = #{bmax}  #{bmax.to_s(2)}"
      bh = (2**bbits - 1).from_3.size2
      a.set_diagonal_at bh-1, abits, 'b'
      bhx = ([0]*abits).concat((1...bh).to_a.reverse)
      puts a.to_s
      puts " " * abits + 'b' * bbits
      puts "====="
      a = Area.new n
      a.set_at 0, n, 'c'
      a.set_at 1, n, 'c'
      a.set_at 2, n, 'c'
      puts a.to_s
      c32 = C32.new n2
      r = c32.crinkle (1 + 2 + 4 + 8 + 16)*3**n
      puts r.inspect
      r.each_with_index do |v, col|
        a.set_at v.size2 - 1, col, 'c'
      end
      puts a.to_s
      puts '----'
      r.each_with_index do |v, col|
        a.set_diagonal_at v.size2 - 1, col, 'c'
      end
      puts a.to_s
      puts ahx.inspect
      puts bhx.inspect
      puts r.map{|x| x.size2}.inspect
      avx = ahx.map{|x| 2**x - 1}
      bvx = bhx.map{|x| 2**x - 1}
      puts avx.inspect
      puts bvx.inspect
      puts r.inspect
      bvx.pop
      all = avx.zip(bvx, r).map(&:sum)
      puts all.inspect
      puts all.map(&:size2).inspect
    end
  end
end
