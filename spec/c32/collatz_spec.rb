# frozen_string_literal: true

module C32
  RSpec.describe Collatz do
    let(:three) { Collatz.new 3 }
    let(:five) { Collatz.new 5 }
    let(:seven) { Collatz.new 7 }
    it { expect(five).to be_a Collatz }
    it { expect(five.dup.next_value.n).to eq 8 }
    it { expect(five.dup.iterate.n).to eq 1 }
    it { expect(three.dup.max).to eq 8 }
    it { expect(five.dup.max).to eq 8 }
    it { expect(seven.dup.max).to eq 26 }
    it { expect(Collatz.new(27).max).to eq 4616 }
    context "Collatz.max" do
      it { expect(Collatz.max 3).to eq [26, 7] }
      it { expect(Collatz.max 4).to eq [80, 15] }
      it { expect(Collatz.max 5).to eq [4616, 31] }
      it { expect(Collatz.max 6).to eq [4616, 63] }
      it { expect(Collatz.max 7).to eq [4616, 111] }
      it { expect(Collatz.max 8).to eq [6560, 255] }
      it { expect(Collatz.max 9).to eq [19682, 511] }
    end
  end
end
