# yo, easy server-side tracking for Google Analytics... hey!
require 'uri'
require 'net/http'
require 'ipaddr'
require 'cgi'
require 'net/http/persistent'

require "#{File.dirname(__FILE__)}/custom_vars"
require "#{File.dirname(__FILE__)}/event"
require "#{File.dirname(__FILE__)}/item"
require "#{File.dirname(__FILE__)}/page_view"
require "#{File.dirname(__FILE__)}/transaction"

module Gabba

  class NoGoogleAnalyticsAccountError < RuntimeError; end
  class NoGoogleAnalyticsDomainError < RuntimeError; end
  class GoogleAnalyticsNetworkError < RuntimeError; end

  class Gabba
    GOOGLE_HOST = "www.google-analytics.com"
    BEACON_PATH = "/__utm.gif"
    USER_AGENT = "Gabba #{VERSION} Agent"

    # Custom var levels
    VISITOR = 1
    SESSION = 2
    PAGE    = 3

    include CustomVars
    include Event
    include Item
    include PageView
    include Transaction

    ESCAPES = %w{ ' ! * ) }

    attr_accessor :utmwv, :utmn, :utmhn, :utmcs, :utmul, :utmdt, :utmp, :utmac, :utmt, :utmcc, :user_agent, :utma, :utmz, :utmr, :utmip

    # Public: Initialize Gabba Google Analytics Tracking Object.
    #
    # ga_acct - A String containing your Google Analytics account id.
    # domain  - A String containing which domain you want the tracking data to be logged from.
    # agent   - A String containing the user agent you want the tracking to appear to be coming from.
    #           Defaults to "Gabba 0.2 Agent" or whatever the corrent version is.
    #
    # Example:
    #
    #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
    #
    def initialize(ga_acct, domain, agent = Gabba::USER_AGENT)
      @utmwv = "4.4sh" # GA version
      @utmcs = "UTF-8" # charset
      @utmul = "en-us" # language

      @utmn = random_id
      @utmhid = random_id

      @utmac = ga_acct
      @utmhn = domain
      @user_agent =  (agent && agent.length > 0) ? agent : Gabba::USER_AGENT

      @custom_vars = []
    end

    # Public: provide the user's __utma and __utmz attributes from analytics cookie, allowing
    # better tracking of user flows
    #
    # Called before page_view etc
    #
    # Examples:
    #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
    #   g.identify_user(cookies[:__utma], cookies[:__utmz])
    #   g.page_view("something", "track/me")
    #
    def identify_user(utma, utmz=nil)
      @utma = utma
      @utmz = utmz
      self
    end

    # Public: provide the utmr attribute, allowing for referral tracking
    #
    # Called before page_view etc
    #
    # Examples:
    #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
    #   g.referer(request.env['HTTP_REFERER'])
    #   g.page_view("something", "track/me")
    #
    def referer(utmr)
      @utmr = utmr
      self
    end

    # Public: provide the utmip attribute, allowing for IP address tracking
    #
    # Called before page_view etc
    #
    # Examples:
    #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
    #   g.ip(request.env["REMOTE_ADDR"])
    #   g.page_view("something", "track/me")
    #
    def ip(utmip)
      @utmip = ::IPAddr.new(utmip).mask(24).to_s
      self
    end

    # create magical cookie params used by GA for its own nefarious purposes
    def cookie_params(utma1 = random_id, utma2 = rand(1147483647) + 1000000000, today = Time.now)
      @utma ||= "1.#{utma1}00145214523.#{utma2}.#{today.to_i}.#{today.to_i}.15"
      @utmz ||= "1.#{today.to_i}.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)"
      "__utma=#{@utma};+__utmz=#{@utmz};"
    end

    # sanity check that we have needed params to even call GA
    def check_account_params
      raise NoGoogleAnalyticsAccountError unless @utmac
      raise NoGoogleAnalyticsDomainError unless @utmhn
    end

    # makes the tracking call to Google Analytics
    def hey(params)
      query = params.map {|k,v| "#{k}=#{URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}" }.join('&')

      @http ||= Net::HTTP::Persistent.new 'Gabba'

      request = Net::HTTP::Get.new("#{BEACON_PATH}?#{query}")
      request["User-Agent"] = URI.escape(user_agent)
      request["Accept"] = "*/*"
      uri = URI "http://#{GOOGLE_HOST}/#{BEACON_PATH}"
      response = @http.request(uri, request)

      raise GoogleAnalyticsNetworkError unless response.code == "200"
      response
    end

    def random_id
      rand 8999999999 + 1000000000
    end

    def escape(t)
      return t if !t || (/\w/ !~ t.to_s)

      t.to_s.gsub(/[\*'!\)]/) do |m|
        "'#{ESCAPES.index(m)}"
      end
    end
  end
end

# Allow for Yo::Gabba::Gabba
module Yo ; Gabba = ::Gabba ; end
