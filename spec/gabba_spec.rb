require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

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

    it "should use Gabba user agent if none is specified" do
      @gabba.user_agent.must_equal(Gabba::Gabba::USER_AGENT)
    end

    it "should use Gabba user agent if nil is specified" do
      Gabba::Gabba.new("abc","123",nil).user_agent.must_equal(Gabba::Gabba::USER_AGENT)
    end

    it "should use Gabba user agent if blank is specified" do
      Gabba::Gabba.new("abc","123","").user_agent.must_equal(Gabba::Gabba::USER_AGENT)
    end
  end

  describe "when tracking custom events" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.event_params("cat1", "act1", "lab1", "val1", false, "6783939397")
    end

    it "must require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).event("cat1", "act1", "lab1", "val1")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "must require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).event("cat1", "act1", "lab1", "val1")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "must be able to create event data" do
      @gabba.event_data("cat1", "act1", "lab1", "val1").must_equal("5(cat1*act1*lab1)(val1)")
    end

    it "must be able to create event data with only category and action" do
      @gabba.event_data("cat1", "act1").must_equal("5(cat1*act1)")
    end

    it "must do event request to google" do
      @gabba.event("cat1", "act1", "lab1", "val1", false, "6783939397").code.must_equal("200")
    end

    it "must be able to send non interactive events" do
      @gabba.event("cat1", "act1", "lab1", "val1", true).code.must_equal("200")
    end

  end

  describe "when tracking an item" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.item_params("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")
    end

    it "must require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "must require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "must do add item request to google" do
      @gabba.add_item("orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397").code.must_equal("200")
    end
  end

  describe "when tracking a transaction" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
      stub_analytics @gabba.transaction_params("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")
    end

    it "must require GA account" do
      lambda {Gabba::Gabba.new(nil, nil).transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")}.must_raise(Gabba::NoGoogleAnalyticsAccountError)
    end

    it "must require GA domain" do
      lambda {Gabba::Gabba.new("abs", nil).transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397")}.must_raise(Gabba::NoGoogleAnalyticsDomainError)
    end

    it "must do transaction request to google" do
      @gabba.transaction("orderid", "9.99", "acme stores", ".25", "1.00", "San Jose", "CA", "United States", "6783939397").code.must_equal("200")
    end
  end

  describe "when using identify_user" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end
    it "must use the supplied utma in cookie_params" do
      # This is how the Google cookie is named
      cookies = { :__utma => "long_code"}
      @gabba.identify_user(cookies[:__utma])
      @gabba.cookie_params.must_match(/utma=long_code;/)
      @gabba.cookie_params.must_match(/utmz=.*direct.*;/)
    end
    it "must use the optionally supplied utmz in cookie_params" do
      cookies = { :__utma => "long_code", :__utmz => "utmz_code" }
      @gabba.identify_user(cookies[:__utma], cookies[:__utmz])
      @gabba.cookie_params.must_match(/utma=long_code;/)
      @gabba.cookie_params.must_match(/utmz=utmz_code;/)
    end
  end

  describe "when using referer" do
    referer = "http://www.someurl.com/blah/blah"
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.referer(referer)
    end
    it "must use the specified referer in page_view_params" do
      @gabba.page_view_params("whocares","doesntmatter")[:utmr].must_equal(referer)
    end
    it "must use the specified referer in event_params" do
      @gabba.event_params("whocares","doesntmatter")[:utmr].must_equal(referer)
    end
    it "must use the specified referer in transaction_params" do
      @gabba.transaction_params('order_id', 'total', 'store_name', 'tax', 'shipping', 'city', 'region', 'country', 'utmhid')[:utmr].must_equal(referer)
    end
    it "must use the specified referer in item_params" do
      @gabba.item_params('order_id', 'item_sku', 'name', 'category', 'price', 'quantity', 'utmhid')[:utmr].must_equal(referer)
    end
  end

  describe "when using ip" do
    ip = "123.123.123.123"
    masked_ip = "123.123.123.0"
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.ip(ip)
    end
    it "must use the specified referer in page_view_params" do
      @gabba.page_view_params("whocares","doesntmatter")[:utmip].must_equal(masked_ip)
    end
    it "must use the specified referer in event_params" do
      @gabba.event_params("whocares","doesntmatter")[:utmip].must_equal(masked_ip)
    end
    it "must use the specified referer in transaction_params" do
      @gabba.transaction_params('order_id', 'total', 'store_name', 'tax', 'shipping', 'city', 'region', 'country', 'utmhid')[:utmip].must_equal(masked_ip)
    end
    it "must use the specified referer in item_params" do
      @gabba.item_params('order_id', 'item_sku', 'name', 'category', 'price', 'quantity', 'utmhid')[:utmip].must_equal(masked_ip)
    end
  end

  describe "setting a custom var" do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end

    it "must return data for a valid var" do
      @gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      @gabba.custom_var_data.must_equal "8(A (B'2'0'1'3)9(Yes)11(2)"
    end

    it "must return data for several valid vards" do
      @gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      @gabba.set_custom_var 2, 'B', 'No', Gabba::Gabba::VISITOR
      @gabba.custom_var_data.must_equal "8(A*B)9(Yes*No)11(2*1)"
    end

    it "must return an empty string if vars aren't set" do
      @gabba.custom_var_data.must_equal ""
    end

    it "must not include var with an empty value" do
      @gabba.set_custom_var 1, 'A', 'Yes', Gabba::Gabba::SESSION
      @gabba.set_custom_var 2, 'B', '',    Gabba::Gabba::VISITOR
      @gabba.set_custom_var 3, 'C', ' ',   Gabba::Gabba::VISITOR
      @gabba.set_custom_var 4, 'D', nil,   Gabba::Gabba::VISITOR
      @gabba.custom_var_data.must_equal "8(A)9(Yes)11(2)"
    end

    it "must mention index of the var if non sequential" do
      @gabba.set_custom_var 2, 'A', 'Y', Gabba::Gabba::SESSION
      @gabba.set_custom_var 4, 'D', 'N', Gabba::Gabba::VISITOR
      @gabba.custom_var_data.must_equal "8(2!A*4!D)9(2!Y*4!N)11(2!2*4!1)"
    end

    it "must raise an error if index is outside the 1-50 (incl) range" do
      lambda { @gabba.set_custom_var(0, 'A', 'B', 1) }.must_raise(RuntimeError)
      lambda { @gabba.set_custom_var(51, 'A', 'B', 1) }.must_raise(RuntimeError)
    end

    it "must raise an error if scope is outside the 1-3 (incl) range" do
      lambda { @gabba.set_custom_var(1, 'A', 'B', 0) }.must_raise(RuntimeError)
      lambda { @gabba.set_custom_var(1, 'A', 'B', 4) }.must_raise(RuntimeError)
    end
  end

  describe 'delete custom var' do
    before do
      @gabba = Gabba::Gabba.new("abc", "123")
      @gabba.utmn = "1009731272"
      @gabba.utmcc = ''
    end

    it "must return data for a valid var" do
      @gabba.set_custom_var 1, 'A (B*\'!)', 'Yes', Gabba::Gabba::SESSION
      @gabba.delete_custom_var 1
      @gabba.custom_var_data.must_equal ""
    end
  end

  def stub_analytics(expected_params)
    s = stub_request(:get, /www.google-analytics.com\/__utm.gif\?utmac=#{expected_params[:utmac]}&.*/).
          to_return(:status => 200, :body => "", :headers => {})
  end
end
