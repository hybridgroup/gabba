module Gabba
  class Gabba
    module PageView
      # Public: Record a page view in Google Analytics
      #
      # title   - String with the page title for thr page view
      # page    - String with the path for the page view
      # utmhid  - String with the unique visitor id, defaults to a new random value
      #
      # Example:
      #
      #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
      #   g.page_view("something", "track/me")
      #
      def page_view(title, page, utmhid = random_id)
        check_account_params
        hey(page_view_params(title, page, utmhid))
      end

      # Public: Renders the page view params data in the format needed for GA
      # Called before actually sending the data along to GA.
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
          :utmcc => @utmcc || cookie_params,
          :utmr => @utmr,
          :utmip => @utmip
        }

        # Add custom vars if present
        cvd = custom_var_data
        options[:utme] = cvd if /\w/ =~ cvd

        options
      end
    end
  end
end
