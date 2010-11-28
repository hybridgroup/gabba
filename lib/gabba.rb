# yo, easy server-side tracking for Google Analytics... hey!
require "open-uri"

module Gabba
  class NoGoogleAnalyticsAccountError < RuntimeError; end
  class NoGoogleAnalyticsDomainError < RuntimeError; end
  
  class Gabba
    BEACON_URL = "http://www.google-analytics.com/__utm.gif"
    TRACKING_URL = "http://www.google-analytics.com/ga.js"
    USER_AGENT = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (.NET CLR 3.5.30729)"
    
    attr_accessor :utmwv, :utmn, :utmhn, :utmcs, :utmul, :utmdt, :utmp, :utmac, :utmt, :utmcc, :user_agent
    
    def initialize(ga_acct, domain, user_agent = USER_AGENT)
      @utmwv = "4.3" # GA version
      @utmcs = "UTF-8" # charset
      @utmul = "en-us" # language
       
      @utmn = rand(8999999999) + 1000000000
      @utmhid = rand(8999999999) + 1000000000
      
      @utmac = ga_acct
      @utmhn = domain
      @user_agent = user_agent
    end
  
    def page_view(title, page, utmhid = rand(8999999999) + 1000000000)
      check_account_params
      Gabba.hey(page_view_params(title, page, utmhid))
    end
  
    def event(category, action, label = nil, value = nil)
      check_account_params
      Gabba.hey(event_params(category, action, label, value))
    end
    
    def page_view_params(title, page, utmhid = rand(8999999999) + 1000000000)
      {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmdt => title,
        :utmhid => utmhid,
        :utmp => page,
        :utmac => @utmac,
        :utmcc => cookie_params
      }
    end
    
    def event_params(category, action, label = nil, value = nil)
      {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmt => 'event',
        :utme => event_data(category, action, label, value),
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmhid => utmhid,
        :utmac => @utmac,
        :utmcc => cookie_params
      }
    end
  
    def event_data(category, action, label = nil, value = nil)
      data = "5(#{category}*action" + (label ? "*#{label})" : ")")      
      data += "(#{value})" if value
    end
  
    def cookie_params(utma1 = rand(89999999) + 10000000, utma2 = rand(1147483647) + 1000000000, today = Time.now)
      "__utma=1.#{utma1}00145214523.#{utma2}.#{today}.#{today}.15;+__utmz=1.#{today}.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none);"
    end
  
    def check_account_params
      raise NoGoogleAnalyticsAccountError unless @utmac
      raise NoGoogleAnalyticsDomainError unless @utmhn
    end

    # makes the tracking call to Google Analytics
    def self.hey(params, referer = "-")
      open("#{BEACON_URL}?hash_to_querystring(params)",
           "User-Agent" => @user_agent,
           "Referer" => referer)
    end
    
    def self.hash_to_querystring(hash = {})
      hash.keys.inject('') do |query_string, key|
        query_string << '&' unless key == hash.keys.first
        query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
      end
    end  
  end
end