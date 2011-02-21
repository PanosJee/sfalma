require 'sfalma'
require 'rails'

module Sfalma
  class Railtie < Rails::Railtie

    initializer "sfalma.middleware" do |app|

      config_file = File.join(Rails.root, "/config/sfalma.yml")
      Sfalma::Config.load config_file if File.exist?(config_file)
      # On Heroku config is loaded via the ENV so no need to load it from the file

      if Sfalma::Config.should_send_to_api?
        Sfalma.logger.info("Loading Sfalma #{Sfalma::VERSION} for #{Rails::VERSION::STRING}")
        app.config.middleware.use "Rack::RailsSfalma"
      end
    end
  end
end
