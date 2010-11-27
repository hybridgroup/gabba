# yo, easy server-side tracking for Google Analytics... hey!
module Gabba
  class Gabba
    BEACON_URL = "http://www.google-analytics.com/__utm.gif"
    TRACKING_URL = "http://www.google-analytics.com/ga.js"

    attr_accessor :utmwv, :utmn, :utmhn, :utmcs, :utmul, :utmdt, :utmp, :utmac, :utmt, :utmcc
  
  
#    private $defaultAnalyticsType = "event";
  
#    private static $trackingDomain = "www.example.com"; // Your host

#    private $utmt; // Analytics type (event)
#    private $utmcc; //Cookie related variables
  
    def initialiaze(domain, ga_acct)
      @utmwv = "4.3" # GA version
      @utmcs = "UTF-8" # charset
      @utmul = "en-us" # language
       
      @utmn = rand(1000000000..9999999999).to_s
      @utmhid = rand(1000000000..9999999999).to_s
      
      @utmhn = domain
      @utmac = ga_acct
    end
  
    def page_view(title, page, utmhid = rand(1000000000..9999999999).to_s)
      "utmwv=#{@utmwv}&utmn=#{@utmn}&utmhn=#{@utmhn}&utmcs=#{@utmcs}&utmul=#{@utmul}&utmdt=#{title}&utmhid=#{utmhid}&utmp=#{page}&utmac=#{@utmac}&utmcc=#{cookie_params}"
    end
  
    def event(category, action, label, value)
    
    end
  
    def cookie_params(today = Time.now)
      "__utma=1.#{rand(10000000..99999999)}00145214523.#{rand(1000000000..2147483647)}.#{today}.#{today}.15;+__utmz=1.#{today}.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none);"
    end
  
  
  
    # def utm_gif_url(tracker = "tracker/serverevent", uservar = "-")
    #   url = "http://www.google-analytics.com/__utm.gif?utmwv=1"
    #   url += "&utmn=" + rand(1000000000..9999999999).to_s
    #   url += "&utmsr=-&utmsc=-&utmul=-&utmje=0&utmfl=-&utmdt=-"
    #   url += "&utmhn=" + domain
    # 
    #   referer = request.env['HTTP_REFERER']
    #   referer = "-" if referer.blank?
    #   url += "&utmr=" + CGI.escape(referer)
    # 
    #   url += "&utmp=" + tracker
    # 
    #   url += "&utmac=" + ga_acct
    # 
    #   cookie =  rand(10000000..99999999).to_s
    #   today = Time.new.getutc
    #   url += "&utmcc=__utma%3D=" + cookie + "." + rand(1000000000..2147483647).to_s + "." + today + "." + today + "." + today + ".2%3B%2B__utmb%3D" + cookie + "%3B%2B__utmc%3D" + cookie + "%3B%2B__utmz%3D" + cookie + "." + today + ".2.2.utmccn%3D(direct)%7Cutmcsr%3D(direct)%7Cutmcmd%3D(none)%3B%2B__utmv%3D" + cookie + "." + uservar + "%3B"
    # end    
  end
end