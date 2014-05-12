module Gabba
  class Gabba
    module Transaction
      # Public:  Track an entire ecommerce transaction to Google Analytics in one call.
      # (http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._trackTrans)
      #
      # order_id    - URL-encoded order ID (required). Maps to utmtid
      # total       - Order total (required). Maps to utmtto
      # store_name  - Affiliation or store name (default: nil). Maps to utmtst
      # tax         - Sales tax (default: nil). Maps to utmttx
      # shipping    - Shipping (default: nil). Maps to utmtsp
      # city        - City (default: nil). Maps to utmtci
      # region      - State or Provance (default: nil). Maps to utmtrg
      # country     - Country (default: nil). Maps to utmtco
      # utmhid      - String with the unique visitor id (default: random_id)
      #
      # Examples:
      #
      #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
      #   g.transaction("123456789", "1000.00")
      #
      #   g = Gabba::Gabba.new("UT-6666", "myawesomeshop.net")
      #   g.transaction("123456789", "1000.00", 'Acme Clothing', '1.29', '5.00', 'Los Angeles', 'California', 'USA')
      #
      def transaction(order_id, total, store_name = nil, tax = nil, shipping = nil, city = nil, region = nil, country = nil, utmhid = random_id)
        check_account_params
        hey(transaction_params(order_id, total, store_name, tax, shipping, city, region, country, utmhid))
      end

      # Public: Renders transaction params data in the format needed for GA
      # Called before actually sending the data along to GA in Gabba#transaction
      def transaction_params(order_id, total, store_name, tax, shipping, city, region, country, utmhid)
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
          :utmtco => country,
          :utmr => @utmr,
          :utmip => @utmip,
          :utme => self.custom_var_data 
        }
      end
    end
  end
end
