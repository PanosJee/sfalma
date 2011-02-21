require 'sfalma'

# If old plugin still installed then we don't want to install this one.
# In production environments we should continue to work as before, but in development/test we should
# advise how to correct the problem and exit
if (defined?(Sfalma::VERSION::STRING) rescue nil) && %w(development test).include?(RAILS_ENV)
  message = %Q(
  ***********************************************************************
  You seem to still have an old version of the Sfalma plugin installed.
  Remove it from /vendor/plugins and try again.
  ***********************************************************************
  )
  puts message
  exit -1
else
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
  rescue => e
    STDERR.puts "Problem starting Sfalma Plugin. Your app will run as normal. #{e.message}"
    Sfalma.logger.error(e.message)
    Sfalma.logger.error(e.backtrace)
  end
end
