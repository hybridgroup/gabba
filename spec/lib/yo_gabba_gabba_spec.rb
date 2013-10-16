require 'spec_helper'

describe Yo::Gabba::Gabba do
  describe "#new" do
    let(:gabba) { Yo::Gabba::Gabba.new 'abc', '123' }

    it "is aliased to Gabba::Gabba#new" do
      expect(gabba).to be_a Gabba::Gabba
    end
  end
end
