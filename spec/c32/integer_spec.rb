# frozen_string_literal: true

RSpec.describe Integer do
  it { expect(0.bits).to eq 0 }
  it { expect(2.bits).to eq 1 }
  it { expect(6.bits).to eq 2 }
  it { expect(7.bits).to eq 3 }
  it { expect(1.from_3).to eq 1 }
  it { expect(2.from_3).to eq 3 }
  it { expect(4.from_3).to eq 9 }
  it { expect(7.from_3).to eq 13 }
  it { expect(9.to_3).to eq [4, 0] }
  it { expect(26.to_3).to eq [0, 7] }
      it "div32" do
        a = 0
        b = 0
        t = 1
        s = false
        #puts "=" * 7
        z = 1
        z = 2**5
        z += 2**9
        z += 2**17
        zh = z
        #puts z.to_s(2).reverse
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
        #puts a.to_s(2).reverse
        #puts b.to_s(2).reverse
        z = zh
        #puts z.to_s(2).reverse
        ax, bx = z.div32
        expect(ax).to eq a
        expect(bx).to eq b
        #puts a.to_s(2).reverse
        #puts b.to_s(2).reverse
      end
end
