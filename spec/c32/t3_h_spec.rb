# frozen_string_literal: true

module C32
  RSpec.describe T3H do
    it { expect(T3H.new).to be_a T3H }
    it { expect(T3H.new.to_r).to eq 1 }
  end
  RSpec.describe T3HBag do
    it { expect(T3HBag.new 3).to be_a T3HBag }
    it { expect(T3HBag.new(3).to_s).to eq "3*<0>" }
    it { expect(T3HBag.new(3).to_r).to eq 3 }
    it { expect(T3HBag.new(3).to_i).to eq 3 }
    it { expect(T3HBag.new(3).md!.to_s).to eq "3*<1>" }
    it { expect(T3HBag.new(3).d!.to_s).to eq "<1>" }
    it { expect(T3HBag.new(3).iter!.to_s).to eq "1/2*<0> + 3*<1>" }
    it { expect(T3HBag.new(3).iterate!.to_i).to eq 1 }
    it do
      b = T3HBag.new 31
      puts b.to_s
      while 1 < b.to_i
        b.iter!
        puts "#{b.to_i}: #{b}"
      end
    end
    it do
      b = T3HBag.new(7).iterate!
      puts b.to_s
      puts b.normalize
    end
  end
end
