require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Gabba::Gabba do
  describe "when tracking page views" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.page_view_params("title", "/page/path", "6783939397")
    end

    it "should require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).page_view("thing", "thing")}.should raise_error(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "should require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).page_view("thing", "thing")}.should raise_error(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "should be able to create page_view_params" do
      @gabba.page_view_params("hiya", "/tracker/page")[:utmdt].should ==("hiya")
    end

    it "should do page view request to google" do
      @gabba.page_view("title", "/page/path", "6783939397").code.should ==("200")
    end

    it "should use Gabba user agent if none is specified" do
      @gabba.user_agent.should ==(Gabba::Gabba::USER_AGENT)
    end

    it "should use Gabba user agent if nil is specified" do
      Gabba::Gabba.new("abc","123",nil).user_agent.should ==(Gabba::Gabba::USER_AGENT)
    end

    it "should use Gabba user agent if blank is specified" do
      Gabba::Gabba.new("abc","123","").user_agent.should ==(Gabba::Gabba::USER_AGENT)
    end
  end

  describe "when tracking custom events" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.event_params("cat1", "act1", "lab1", "val1", false, "6783939397")
    end

    it "should require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).event("cat1", "act1", "lab1", "val1")}.should raise_error(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "should require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).event("cat1", "act1", "lab1", "val1")}.should raise_error(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "should be able to create event data" do
      @gabba.event_data("cat1", "act1", "lab1", "val1").should ==("5(cat1*act1*lab1)(val1)")
    end

    it "should be able to create event data with only category and action" do
      @gabba.event_data("cat1", "act1").should ==("5(cat1*act1)")
    end

    it "should do event request to google" do
      @gabba.event("cat1", "act1", "lab1", "val1", false, "6783939397").code.should ==("200")
    end

    it "should be able to send non interactive events" do
      @gabba.event("cat1", "act1", "lab1", "val1", true).code.should ==("200")
    end

  end

  describe "when tracking an item" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.item_params("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")
    end

    it "should require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")}.should raise_error(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "should require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")}.should raise_error(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "should do add item request to google" do
      @gabba.add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397").code.should ==("200")
    end
  end

  describe "when tracking a transaction" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.transaction_params("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")
    end

    it "should require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")}.should raise_error(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "should require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")}.should raise_error(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "should do transaction request to google" do
      @gabba.transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397").code.should ==("200")
    end
  end

  describe "when using identify_user" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end
    it "should use the supplied utma in cookie_params" do
      # This is how the Google cookie is named
      cookies = { :__utma => "long_code"}
      @gabba.identify_user(cookies[:__utma])
      @gabba.cookie_params.should match(/utma=long_code;/)
      @gabba.cookie_params.should match(/utmz=.*direct.*;/)
    end
    it "should use the optionally supplied utmz in cookie_params" do
      cookies = { :__utma => "long_code", :__utmz => "utmz_code" }
      @gabba.identify_user(cookies[:__utma], cookies[:__utmz])
      @gabba.cookie_params.should match(/utma=long_code;/)
      @gabba.cookie_params.should match(/utmz=utmz_code;/)
    end
  end

  describe "when using referer" do
    referer = "http://www.someurl.com/blah/blah"
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.referer(referer)
    end
    it "should use the specified referer in page_view_params" do
      @gabba.page_view_params("whocares","doesntmatter")[:utmr].should ==(referer)
    end
    it "should use the specified referer in event_params" do
      @gabba.event_params("whocares","doesntmatter")[:utmr].should ==(referer)
    end
    it "should use the specified referer in transaction_params" do
      @gabba.transaction_params('order_id', 'total', 'store_name', 'tax', 'shipping', 'city', 'region', 'country', 'utmhid')[:utmr].should ==(referer)
    end
    it "should use the specified referer in item_params" do
      @gabba.item_params('order_id', 'item_sku', 'name', 'category', 'price', 'quantity', 'utmhid')[:utmr].should ==(referer)
    end
  end

  describe "when using ip" do
    ip = "123.123.123.123"
    masked_ip = "123.123.123.0"
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.ip(ip)
    end
    it "should use the specified referer in page_view_params" do
      @gabba.page_view_params("whocares","doesntmatter")[:utmip].should ==(masked_ip)
    end
    it "should use the specified referer in event_params" do
      @gabba.event_params("whocares","doesntmatter")[:utmip].should ==(masked_ip)
    end
    it "should use the specified referer in transaction_params" do
      @gabba.transaction_params('order_id', 'total', 'store_name', 'tax', 'shipping', 'city', 'region', 'country', 'utmhid')[:utmip].should ==(masked_ip)
    end
    it "should use the specified referer in item_params" do
      @gabba.item_params('order_id', 'item_sku', 'name', 'category', 'price', 'quantity', 'utmhid')[:utmip].should ==(masked_ip)
    end
  end

  describe "setting a custom var" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end

    it "should return data for a valid var" do
      @gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      @gabba.custom_var_data.should == "8(A (B'2'0'1'3)9(Yes)11(2)"
    end

    it "should return data for several valid vards" do
      @gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      @gabba.set_custom_var 2, 'B', 'No', Gabba::Gabba::VISITOR
      @gabba.custom_var_data.should == "8(A*B)9(Yes*No)11(2*1)"
    end

    it "should return an empty string if vars aren't set" do
      @gabba.custom_var_data.should == ""
    end

    it "should not include var with an empty value" do
      @gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      @gabba.set_custom_var 2, 'B', '',    Gabba::Gabba::VISITOR
      @gabba.set_custom_var 3, 'C', ' ',   Gabba::Gabba::VISITOR
      @gabba.set_custom_var 4, 'D', nil,   Gabba::Gabba::VISITOR
      @gabba.custom_var_data.should == "8(A)9(Yes)11(2)"
    end

    it "should mention index of the var if non sequential" do
      @gabba.set_custom_var 2, 'A', 'Y', Gabba::Gabba::SESSION
      @gabba.set_custom_var 4, 'D', 'N', Gabba::Gabba::VISITOR
      @gabba.custom_var_data.should == "8(2!A*4!D)9(2!Y*4!N)11(2!2*4!1)"
    end

    it "should raise an error if index is outside the 1-50 (incl) range" do
      lambda { @gabba.set_custom_var(0, 'A', 'B', 1) }.should raise_error(RuntimeError)
      lambda { @gabba.set_custom_var(51, 'A', 'B', 1) }.should raise_error(RuntimeError)
    end

    it "should raise an error if scope is outside the 1-3 (incl) range" do
      lambda { @gabba.set_custom_var(1, 'A', 'B', 0) }.should raise_error(RuntimeError)
      lambda { @gabba.set_custom_var(1, 'A', 'B', 4) }.should raise_error(RuntimeError)
    end
  end

  describe 'delete custom var' do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end

    it "should return data for a valid var" do
      @gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      @gabba.delete_custom_var 1
      @gabba.custom_var_data.should == ""
    end
  end

  describe "USER_AGENT" do
    it "contains the current Gabba version" do
      Gabba::Gabba::USER_AGENT.should == "Gabba #{Gabba::VERSION} Agent"
    end
  end

  describe 'Yo::Gabba::Gabba' do
    before do
      @gabba = Yo::Gabba::Gabba.new('abc', '123')
    end

    it 'should be aliased to Gabba::Gabba' do
      @gabba.should be_instance_of Gabba::Gabba
    end
  end
end
