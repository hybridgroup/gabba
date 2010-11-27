require File.dirname(__FILE__) + '/spec_helper'

describe Gabba::Gabba do
  before do
    @gabba = Gabba::Gabba.new
  end
 
  describe "yo" do
    it "should respond positively" do
      @gabba.must_equal "OHAI!"
    end
  end
 
end
