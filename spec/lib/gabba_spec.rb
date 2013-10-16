require 'spec_helper'

describe Gabba::Gabba do
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
end
