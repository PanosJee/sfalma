module Sfalma
  class StartupException < StandardError;
  end
  class Startup
    class << self
      def announce
        if Config.api_key.blank?
          raise StartupException, 'API Key must be configured (/config/sfalma.yml)'
        end
        Remote.startup_announce(::Sfalma::ApplicationEnvironment.to_hash('rails'))
      end
    end
  end
end