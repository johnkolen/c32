# frozen_string_literal: true

RSpec.describe Integer do
  it { expect(0.bits).to eq 0 }
  it { expect(2.bits).to eq 1 }
  it { expect(6.bits).to eq 2 }
  it { expect(7.bits).to eq 3 }
  it { expect(1.to_3).to eq 1 }
  it { expect(2.to_3).to eq 3 }
  it { expect(4.to_3).to eq 9 }
  it { expect(7.to_3).to eq 13 }
end
