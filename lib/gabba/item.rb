module Gabba
  class Gabba
    module Item
      # Public:  Track an item purchased in an ecommerce transaction to Google Analytics.
      # (http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addItem)
      def add_item(order_id, item_sku, price, quantity, name = nil, category = nil, utmhid = random_id)
        check_account_params
        hey(item_params(order_id, item_sku, name, category, price, quantity, utmhid))
      end

      # Public: Renders item purchase params data in the format needed for GA
      # Called before actually sending the data along to GA in Gabba#add_item
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
          :utmiqt => quantity,
          :utmr => @utmr,
          :utmip => @utmip
        }
      end
    end
  end
end
