require 'spec_helper'

describe Gabba::Gabba do
  describe "#set_custom_var/#custom_var_data" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "can return data for a valid custom variable" do
      gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      expect(gabba.custom_var_data).to eq "8(A (B'2'0'1'3)9(Yes)11(2)"
    end

    it "can return data for several valid custom variables" do
      gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      gabba.set_custom_var 2, 'B', 'No', Gabba::Gabba::VISITOR
      expect(gabba.custom_var_data).to eq "8(A*B)9(Yes*No)11(2*1)"
    end

    it "defaults to an empty string" do
      expect(gabba.custom_var_data).to eq ""
    end

    it "doesn't return data for a variable with an empty value" do
      gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      gabba.set_custom_var 2, 'B', '',    Gabba::Gabba::VISITOR
      gabba.set_custom_var 3, 'C', ' ',   Gabba::Gabba::VISITOR
      gabba.set_custom_var 4, 'D', nil,   Gabba::Gabba::VISITOR
      expect(gabba.custom_var_data).to eq "8(A)9(Yes)11(2)"
    end

    it "includes indices of the variables if non-sequential" do
      gabba.set_custom_var 2, 'A', 'Y', Gabba::Gabba::SESSION
      gabba.set_custom_var 4, 'D', 'N', Gabba::Gabba::VISITOR
      expect(gabba.custom_var_data).to eq "8(2!A*4!D)9(2!Y*4!N)11(2!2*4!1)"
    end

    it "raises an error if index is outside the 1-50 (incl) range" do
      expect{gabba.set_custom_var(0, 'A', 'B', 1)}.to raise_error(RuntimeError)
      expect{gabba.set_custom_var(51, 'A', 'B', 1)}.to raise_error(RuntimeError)
    end

    it "raises an error if scope is outside the 1-3 (incl) range" do
      expect{gabba.set_custom_var(1, 'A', 'B', 0)}.to raise_error(RuntimeError)
      expect{gabba.set_custom_var(1, 'A', 'B', 4)}.to raise_error(RuntimeError)
    end
  end

  describe "#delete_custom_var" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "deletes the matching variable" do
      gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      gabba.delete_custom_var 1
      expect(gabba.custom_var_data).to eq ""
    end
  end
end
