require 'ooorest/config/proxyable/proxy'
module Ooorest
  module Config
    module Proxyable
      attr_accessor :bindings

      def with(bindings = {})
        Ooorest::Config::Proxyable::Proxy.new(self, bindings)
      end
    end
  end
end
