require 'sfalma'
begin

  if (Rails::VERSION::MAJOR < 3)    
    Sfalma::Config.load(File.join(RAILS_ROOT, "/config/sfalma.yml"))
    if Sfalma::Config.should_send_to_api?
      Sfalma.logger.info("Loading Sfalma #{Sfalma::VERSION} for #{Rails::VERSION::STRING}")      
      require File.join('sfalma', 'integration', 'rails')    
      require File.join('sfalma', 'integration', 'dj') if defined?(Delayed::Job)
    end
  else
    Sfalma::Config.load(File.join(Rails.root, "/config/sfalma.yml"))
    
    if Sfalma::Config.should_send_to_api?
      Sfalma.logger.info("Loading Sfalma #{Sfalma::VERSION} for #{Rails::VERSION::STRING}")      
      Rails.configuration.middleware.use "Rack::RailsSfalma"
      require File.join('sfalma', 'integration', 'dj') if defined?(Delayed::Job)
    end      
  end

  Sfalma::Startup.announce
rescue => e
  STDERR.puts "Problem starting Sfalma Plugin. Your app will run as normal. #{e.message}"
  Sfalma.logger.error(e.message)
  Sfalma.logger.error(e.backtrace)
end

