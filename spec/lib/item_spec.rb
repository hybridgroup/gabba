require 'spec_helper'

describe Gabba::Gabba do
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
end
