# frozen_string_literal: true

module C32
  RSpec.describe C32 do
    let(:seven) { C32.new 7 }
    let(:six) { C32.new 6 }
    it { expect(C32.new 1).to be_a C32 }
    it { expect(seven.to_i).to eq 7 }
    it { expect(seven.dup.tbl.object_id).not_to eq seven.tbl.object_id }
    it { expect(seven.dup.mul3.to_i).to eq 21 }
    it { expect{seven.dup.add1.to_i}.to raise_error(String) }
    it { expect(six.dup.add1.to_i).to eq 7 }
    it { expect(six.dup.div2.to_i).to eq 3 }
    it { x = C32.new(3); x.mul3 ; expect(x.to_i).to eq 9
      x.add1; expect(x.to_i).to eq 10
      x.div2;  expect(x.to_i).to eq 5
    }
    it { x = C32.new(3); x.mul3; expect(x.to_i).to eq 9
      x.add1; expect(x.to_i).to eq 10
      x.tbl[x.zero] = 0; expect(x.to_i).to eq 6
      x.fill_left(4, x.zero); expect(x.to_i).to eq 10
    }
    it do
      x = C32.new 2
      x.tbl[x.zero] = 17
      puts x.to_s
      expect(x.to_i).to eq 84
      x.div2
      puts x.to_s
      expect(x.to_i).to eq 42
      x.adj_10001
      puts x.to_s
      expect(x.to_i).to eq 42
    end
    it do
      x = C32.new 7
      x.tbl[x.zero + 1] = 0
      x.tbl[x.zero] = 7
      puts x.to_s
      puts x.to_i
      puts "===="
      x.mul3.add1.div2
      puts x.to_s
      puts x.to_i
      expect(x.to_i).to eq 26
      x.rotate
      puts x.to_s
      puts x.to_i
      puts "===="
      expect(x.to_i).to eq 26

    end

    it "does collatz" do
      n = 7
      x = C32.new n
      max_iter = 13
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

    it "collatz class" do
      stats = C32.collatz 7
      puts stats.inspect
    end
    it "collatz class" do
      stats = C32.collatz 31
      puts stats.inspect
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
