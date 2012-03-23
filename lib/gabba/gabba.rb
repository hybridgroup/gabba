# yo, easy server-side tracking for Google Analytics... hey!
require "uri"
require "net/http"
require 'cgi'
require File.dirname(__FILE__) + '/version'

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

    ESCAPES = %w{ ' ! * ) }
    
    attr_accessor :utmwv, :utmn, :utmhn, :utmcs, :utmul, :utmdt, :utmp, :utmac, :utmt, :utmcc, :user_agent
    
    def initialize(ga_acct, domain, agent = Gabba::USER_AGENT)
      @utmwv = "4.4sh" # GA version
      @utmcs = "UTF-8" # charset
      @utmul = "en-us" # language
       
      @utmn = random_id
      @utmhid = random_id
      
      @utmac = ga_acct
      @utmhn = domain
      @user_agent = agent

      @custom_vars = []
    end
  
    def set_custom_var(index, name, value, scope)
      raise "Index must be between 1 and 5" unless (1..5).include?(index)
      raise "Scope must be 1 (VISITOR), 2 (SESSION) or 3 (PAGE)" unless (1..3).include?(scope)
      
      @custom_vars[index] = [ name, value, scope ]
    end
    
    def delete_custom_var(index)
      raise "Index must be between 1 and 5" unless (1..5).include?(index)

      @custom_vars.delete_at(index)
    end
    
    def custom_var_data
      names  = []
      values = []
      scopes = []
      
      idx = 1
      @custom_vars.each_with_index do |(n, v, s), i|
        next if !n || !v || (/\w/ !~ n) || (/\w/ !~ v)
        prefix = "#{i}!" if idx != i
        names  << "#{prefix}#{escape(n)}"
        values << "#{prefix}#{escape(v)}"
        scopes << "#{prefix}#{escape(s)}"
        idx = i + 1
      end
      
      names.empty? ? "" : "8(#{names.join('*')})9(#{values.join('*')})11(#{scopes.join('*')})"
    end
    
    def page_view(title, page, utmhid = random_id)
      check_account_params
      hey(page_view_params(title, page, utmhid))
    end

    def page_view_params(title, page, utmhid = random_id)
      options = {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmdt => title,
        :utmhid => utmhid,
        :utmp => page,
        :utmac => @utmac,
        :utmcc => @utmcc || cookie_params
      }

      # Add custom vars if present
      cvd = custom_var_data
      options[:utme] = cvd if /\w/ =~ cvd

      options
    end
  
    def event(category, action, label = nil, value = nil, utmni = false, utmhid = random_id)
      check_account_params
      hey(event_params(category, action, label, value, utmni, utmhid))
    end

    def event_params(category, action, label = nil, value = nil, utmni = false, utmhid = false)
      raise ArgumentError.new("utmni must be a boolean") if (utmni.class != TrueClass && utmni.class != FalseClass)
      {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmni => (1 if utmni), # 1 for non interactive event, excluded from bounce calcs
        :utmt => 'event',
        :utme => "#{event_data(category, action, label, value)}#{custom_var_data}",
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmhid => utmhid,
        :utmac => @utmac,
        :utmcc => @utmcc || cookie_params
      }
    end

    def event_data(category, action, label = nil, value = nil)
      data = "5(#{category}*#{action}" + (label ? "*#{label})" : ")")
      data += "(#{value})" if value
      data
    end
    
    def transaction(order_id, total, store_name = nil, tax = nil, shipping = nil, city = nil, region = nil, country = nil, utmhid = random_id)
      check_account_params
      hey(transaction_params(order_id, total, store_name, tax, shipping, city, region, country, utmhid))
    end

    def transaction_params(order_id, total, store_name, tax, shipping, city, region, country, utmhid)
      # '1234',           // utmtid URL-encoded order ID - required
      # 'Acme Clothing',  // utmtst affiliation or store name
      # '11.99',          // utmtto total - required
      # '1.29',           // utmttx tax
      # '5',              // utmtsp shipping
      # 'San Jose',       // utmtci city
      # 'California',     // utmtrg state or province
      # 'USA'             // utmtco country
      {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmt => 'tran',
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmhid => utmhid,
        :utmac => @utmac,
        :utmcc => @utmcc || cookie_params,
        :utmtid => order_id,
        :utmtst => store_name,
        :utmtto => total,
        :utmttx => tax,
        :utmtsp => shipping,
        :utmtci => city,
        :utmtrg => region,
        :utmtco => country
      }
    end
    
    def add_item(order_id, item_sku, price, quantity, name = nil, category = nil, utmhid = random_id)
      check_account_params
      hey(item_params(order_id, item_sku, name, category, price, quantity, utmhid))
    end
    
    def item_params(order_id, item_sku, name, category, price, quantity, utmhid)
      # '1234',           // utmtid URL-encoded order ID - required
      # 'DD44',           // utmipc SKU/code - required
      # 'T-Shirt',        // utmipn product name
      # 'Green Medium',   // utmiva category or variation
      # '11.99',          // utmipr unit price - required
      # '1'               // utmiqt quantity - required
      {
        :utmwv => @utmwv,
        :utmn => @utmn,
        :utmhn => @utmhn,
        :utmt => 'item',
        :utmcs => @utmcs,
        :utmul => @utmul,
        :utmhid => utmhid,
        :utmac => @utmac,
        :utmcc => @utmcc || cookie_params,
        :utmtid => order_id,
        :utmipc => item_sku,
        :utmipn => name,
        :utmiva => category,
        :utmipr => price,
        :utmiqt => quantity
      }
    end
  
    # create magical cookie params used by GA for its own nefarious purposes
    def cookie_params(utma1 = random_id, utma2 = rand(1147483647) + 1000000000, today = Time.now)
      "__utma=1.#{utma1}00145214523.#{utma2}.#{today.to_i}.#{today.to_i}.15;+__utmz=1.#{today.to_i}.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none);"
    end

    # sanity check that we have needed params to even call GA
    def check_account_params
      raise NoGoogleAnalyticsAccountError unless @utmac
      raise NoGoogleAnalyticsDomainError unless @utmhn
    end

    # makes the tracking call to Google Analytics
    def hey(params)
      query = params.map {|k,v| "#{k}=#{URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}" }.join('&')

      response = Net::HTTP.start(GOOGLE_HOST) do |http|
        request = Net::HTTP::Get.new("#{BEACON_PATH}?#{query}")
        request["User-Agent"] = URI.escape(user_agent)
        request["Accept"] = "*/*"
        http.request(request)
      end

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
    
  end # Gabba Class

end
