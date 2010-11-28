require File.dirname(__FILE__) + '/spec_helper'

describe Gabba::Gabba do
  
  it "must require GA account" do
    lambda {Gabba::Gabba.new(nil, nil).page_view("thing", "thing")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
  end
  
  it "must require GA domain" do
    lambda {Gabba::Gabba.new("abs", nil).page_view("thing", "thing")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
  end
  
  describe "when tracking page views" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
    end
    
    it "must be able to create page_view_params" do
      @gabba.page_view_params("hiya", "/tracker/page")[:utmdt].must_equal("hiya")
    end

    it "must be able to create hash of page_view_params" do
      Gabba::Gabba.hash_to_querystring(@gabba.page_view_params("hiya", "/tracker/page")).wont_be_nil
    end
  end

 
end
