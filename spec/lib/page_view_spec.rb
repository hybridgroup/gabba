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
end
