# frozen_string_literal: true

module C32
  RSpec.describe T235 do
    it { expect(T235.new 0, 0, 1).to be_a T235 }
    it { expect(T235.new(3, 2 , 1).to_i).to eq 360 }
    it { expect(3072.to_235).to eq [10, 1, 0]}
    context "minimal" do
      it { expect(T235::minimal 3).to eq [3] }
      it { expect(T235::minimal 6).to eq [6] }
      it { expect(T235::minimal 30).to eq [30] }
      it { expect(T235::minimal 31).to eq [1, 30] }
      it { expect(T235::minimal 19).to eq [1, 18] }
    end
    it do
      c = Collatz.new 27
      c.iterate do |n|
        puts "#{'%4d' % n}: #{T235.minimal(n).inspect}   #{T235.minimal_terms(n).map(&:to_s).join(' ')} "
      end
    end
  end
end
