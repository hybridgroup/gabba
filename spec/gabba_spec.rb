require File.dirname(__FILE__) + '/spec_helper'

describe Gabba::Gabba do
  
  describe "when tracking page views" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.page_view_params("title", "/page/path", "6783939397")
    end
    
    it "must require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).page_view("thing", "thing")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "must require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).page_view("thing", "thing")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
    end
    
    it "must be able to create page_view_params" do
      @gabba.page_view_params("hiya", "/tracker/page")[:utmdt].must_equal("hiya")
    end

    it "must do page view request to google" do
      @gabba.page_view("title", "/page/path", "6783939397").code.must_equal("200")
    end
  end

  describe "when tracking custom events" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.event_params("cat1", "act1", "lab1", "val1", "6783939397")
    end
    
    it "must require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).event("cat1", "act1", "lab1", "val1")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "must require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).event("cat1", "act1", "lab1", "val1")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
    end
    
    it "must be able to create event data" do
      @gabba.event_data("cat1", "act1", "lab1", "val1").wont_be_nil
    end
    
    it "must do event request to google" do
      @gabba.event("cat1", "act1", "lab1", "val1", "6783939397").code.must_equal("200")
    end

  end

  def stub_analytics(expected_params)
    s = stub_request(:get, /www.google-analytics.com\/__utm.gif\?utmac=#{expected_params[:utmac]}&.*/).
          to_return(:status => 200, :body => "", :headers => {})
  end
end
