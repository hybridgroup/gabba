require 'spec_helper'

describe Gabba::Gabba do
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
end
