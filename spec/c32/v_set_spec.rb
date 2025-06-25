# frozen_string_literal: true

module C32
  RSpec.describe VSet do
    let(:vset) { VSet.new 0, 1, 2, 3, 5, 7, 9 }
    it { expect(VSet.new(0)).to be_a VSet }
    it { expect(vset.size).to eq 7 }
    it { expect(vset.max).to eq 9 }
    it { expect(vset.map{|x| x + 1}.to_a).to eq [1, 2, 3, 4, 6, 8, 10] }
    it { expect(vset.union(VSet.new(1, 4)).range).to eq 0..5 }
    it { expect(vset.union(VSet.new(1, 4)).values).to eq [7, 9] }
  end
end
