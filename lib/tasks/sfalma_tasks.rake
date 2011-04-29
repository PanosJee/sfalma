namespace :sfalma do
  desc 'Send a test exception to Sfalma.'
  task :test => :environment do
    unless Sfalma::Config.api_key.blank?
      puts "Sending test exception to Sfalma."
      require "sfalma/integration/tester"
      Sfalma::Integration.test
      puts "Done."
    end
  end
end