require 'spec_helper'

describe Gabba::Gabba do
  describe "#page_view" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "requires a Google Analytics account" do
      expect{
        Gabba::Gabba.new(nil, nil).page_view('thing', 'thing')
      }.to raise_error Gabba::NoGoogleAnalyticsAccountError
    end

    it "requires a Google Analytics domain" do
      expect{
        Gabba::Gabba.new('abs', nil).page_view('thing', 'thing')
      }.to raise_error Gabba::NoGoogleAnalyticsDomainError
    end

    it "sends the request to Google" do
      stub_analytics gabba.page_view_params 'title', '/page/path', '6783939397'
      page_view = gabba.page_view 'title', '/page/path', '6783939397'
      expect(page_view.code).to eq '200'
    end
  end

  describe '#page_view_params' do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    it "returns the params to be sent to Google" do
      params = gabba.page_view_params 'hiya', '/tracker/page'
      expect(params[:utmdt]).to eq 'hiya'
    end
  end

  describe '#user_agent' do
    describe "when given" do
      let(:gabba) { Gabba::Gabba.new 'abc', '123', 'CUSTOM USER AGENT' }

      it 'returns the provided User Agent' do
        expect(gabba.user_agent).to eq 'CUSTOM USER AGENT'
      end
    end

    describe "when not specified" do
      let(:gabba) { Gabba::Gabba.new 'abc', '123' }

      it 'returns the default User Agent' do
        expect(gabba.user_agent).to eq Gabba::Gabba::USER_AGENT
      end
    end

    describe "when nil" do
      let(:gabba) { Gabba::Gabba.new 'abc', '123', nil }

      it 'returns the default User Agent' do
        expect(gabba.user_agent).to eq Gabba::Gabba::USER_AGENT
      end
    end

    describe "default" do
      it "includes the current version number" do
        expect(Gabba::Gabba::USER_AGENT).to eq "Gabba #{Gabba::VERSION} Agent"
      end
    end

    describe "when empty string" do
      let(:gabba) { Gabba::Gabba.new 'abc', '123', '' }

      it 'returns the default User Agent' do
        expect(gabba.user_agent).to eq Gabba::Gabba::USER_AGENT
      end
    end
  end

  describe "#event" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "requires a Google Analytics account" do
      expect{
        Gabba::Gabba.new(nil, nil).event("cat1", "act1", "lab1", "val1")
      }.to raise_error Gabba::NoGoogleAnalyticsAccountError
    end

    it "requires a Google Analytics domain" do
      expect{
        Gabba::Gabba.new('abs', nil).event("cat1", "act1", "lab1", "val1")
      }.to raise_error Gabba::NoGoogleAnalyticsDomainError
    end

    it "sends the request to Google" do
      stub_analytics(
        gabba.event_params "cat1", "act1", "lab1", "val1", false, "6783939397"
      )
      event = gabba.event "cat1", "act1", "lab1", "val1", false, "6783939397"
      expect(event.code).to eq '200'
    end

    it 'can send non-interactive events to Google' do
      stub_analytics(gabba.event_params "cat1", "act1", "lab1", "val1")
      event = gabba.event "cat1", "act1", "lab1", "val1"
      expect(event.code).to eq '200'
    end
  end

  describe '#event_data' do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    it 'returns data formatted to send to Google' do
      data = gabba.event_data("cat1", "act1", "lab1", "val1")
      expect(data).to eq "5(cat1*act1*lab1)(val1)"
    end

    it 'can create event data with only category and action' do
      expect(gabba.event_data("cat1", "act1")).to eq "5(cat1*act1)"
    end
  end

  describe "#add_item" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "requires a Google Analytics account" do
      expect{
        Gabba::Gabba.new(nil, nil).add_item(
          "orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397"
        )
      }.to raise_error Gabba::NoGoogleAnalyticsAccountError
    end

    it "requires a Google Analytics domain" do
      expect{
        Gabba::Gabba.new('abs', nil).add_item(
          "orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397"
        )
      }.to raise_error Gabba::NoGoogleAnalyticsDomainError
    end

    it "sends the 'add item' request to Google" do
      stub_analytics(
        gabba.item_params(
          "orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397"
        )
      )
      item =  gabba.add_item(
        "orderid", "1234", "widget", "widgets", "9.99", "1", "6783939397"
      )
      expect(item.code).to eq '200'
    end
  end

  describe '#transaction' do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "requires a Google Analytics account" do
      expect{
        Gabba::Gabba.new(nil, nil).transaction(
          "orderid",
          "9.99",
          "acme stores",
          ".25",
          "1.00",
          "San Jose",
          "CA",
          "United States",
          "6783939397"
        )
      }.to raise_error Gabba::NoGoogleAnalyticsAccountError
    end

    it "requires a Google Analytics domain" do
      expect{
        Gabba::Gabba.new('abs', nil).transaction(
          "orderid", "9.99",
          "acme stores", ".25",
          "1.00", "San Jose",
          "CA", "United States", "6783939397"
        )
      }.to raise_error Gabba::NoGoogleAnalyticsDomainError
    end

    it "makes a transaction request to Google" do
      stub_analytics(
        gabba.transaction_params(
          "orderid", "9.99",
          "acme stores", ".25",
          "1.00", "San Jose",
          "CA", "United States", "6783939397"
        )
      )
      transaction = gabba.transaction(
        "orderid", "9.99",
        "acme stores", ".25",
        "1.00", "San Jose",
        "CA", "United States", "6783939397"
      )
      expect(transaction.code).to eq '200'
    end
  end

  describe "#identify_user" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
    end

    it "uses the supplied utma value in the cookie params" do
      cookies = { :__utma => 'long_code' }
      gabba.identify_user cookies[:__utma]

      expect(gabba.cookie_params).to match /utma=long_code;/
      expect(gabba.cookie_params).to match /utmz=.*direct.*;/
    end

    it "should use the optional utmz value in the cookie params" do
      cookies = { :__utma => 'long_code', :__utmz => 'utmz_code' }
      gabba.identify_user cookies[:__utma], cookies[:__utmz]

      expect(gabba.cookie_params).to match /utma=long_code;/
      expect(gabba.cookie_params).to match /utmz=utmz_code;/
    end
  end

  describe "#referer" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }
    let(:referer) { "http://www.someurl.com/blah/blah" }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
      gabba.referer referer
    end

    it "uses the specified referer in page_view_params" do
      page_view_params = gabba.page_view_params 'whocares', 'doesntmatter'
      expect(page_view_params[:utmr]).to eq referer
    end

    it "uses the specified referer in event_params" do
      event_params = gabba.event_params 'whocares', 'doesntmatter'
      expect(event_params[:utmr]).to eq referer
    end

    it "should use the specified referer in transaction_params" do
      transaction_params = gabba.transaction_params(
        'order_id', 'total', 'store_name',
        'tax', 'shipping', 'city',
        'region', 'country', 'utmhid'
      )
      expect(transaction_params[:utmr]).to eq referer
    end

    it "should use the specified referer in item_params" do
      item_params = gabba.item_params(
        'order_id', 'item_sku', 'name',
        'category', 'price', 'quantity', 'utmhid'
      )
      expect(item_params[:utmr]).to eq referer
    end
  end

  describe "#ip" do
    let(:gabba) { Gabba::Gabba.new 'abc', '123' }
    let(:ip) { "192.168.1.1" }
    let(:masked_ip) { "192.168.1.0" }

    before do
      gabba.utmn = '1009731272'
      gabba.utmcc = ''
      gabba.ip ip
    end

    it "uses the specified IP in page_view_params" do
      page_view_params = gabba.page_view_params 'whocares', 'doesntmatter'
      expect(page_view_params[:utmip]).to eq masked_ip
    end

    it "uses the specified IP in event_params" do
      event_params = gabba.event_params 'whocares', 'doesntmatter'
      expect(event_params[:utmip]).to eq masked_ip
    end

    it "should use the specified IP in transaction_params" do
      transaction_params = gabba.transaction_params(
        'order_id', 'total', 'store_name',
        'tax', 'shipping', 'city',
        'region', 'country', 'utmhid'
      )
      expect(transaction_params[:utmip]).to eq masked_ip
    end

    it "should use the specified IP in item_params" do
      item_params = gabba.item_params(
        'order_id', 'item_sku', 'name',
        'category', 'price', 'quantity', 'utmhid'
      )
      expect(item_params[:utmip]).to eq masked_ip
    end
  end

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

describe Yo::Gabba::Gabba do
  describe "#new" do
    let(:gabba) { Yo::Gabba::Gabba.new 'abc', '123' }

    it "is aliased to Gabba::Gabba#new" do
      expect(gabba).to be_a Gabba::Gabba
    end
  end
end
