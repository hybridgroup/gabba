require 'spec_helper'
describe Gabba::Gabba do
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
end
