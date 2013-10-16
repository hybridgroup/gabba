module Gabba
  class Gabba
    module CustomVars
      # Public: Set a custom variable to be passed along and logged by Google Analytics
      # (http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html)
      #
      # index  - Integer between 1 and 50 for this custom variable (limit is 5 normally, but is 50 for GA Premium)
      # name   - String with the name of the custom variable
      # value  - String with the value for teh custom variable
      # scope  - Integer with custom variable scope must be 1 (VISITOR), 2 (SESSION) or 3 (PAGE)
      #
      # Example:
      #
      #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
      #   g.set_custom_var(1, 'awesomeness', 'supreme', Gabba::VISITOR)
      #   # => ['awesomeness', 'supreme', 1]
      #
      # Returns array with the custom variable data
      def set_custom_var(index, name, value, scope)
        raise "Index must be between 1 and 50" unless (1..50).include?(index)
        raise "Scope must be 1 (VISITOR), 2 (SESSION) or 3 (PAGE)" unless (1..3).include?(scope)

        @custom_vars[index] = [ name, value, scope ]
      end

      # Public: Delete a previously set custom variable so if is not passed along and logged by Google Analytics
      # (http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html)
      #
      # index  - Integer between 1 and 5 for this custom variable
      #
      # Example:
      #   g = Gabba::Gabba.new("UT-1234", "mydomain.com")
      #   g.delete_custom_var(1)
      #
      def delete_custom_var(index)
        raise "Index must be between 1 and 5" unless (1..5).include?(index)

        @custom_vars.delete_at(index)
      end

      # Public: Renders the custom variable data in the format needed for GA
      # (http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html)
      # Called before actually sending the data along to GA.
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
    end
  end
end
