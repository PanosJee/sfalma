module Sfalma
  module Integration
    class SfalmaTestException <StandardError;
    end

    def self.test
      begin
        raise SfalmaTestException.new, 'Test exception'
      rescue Exception => e
        unless Sfalma::Remote.error(Sfalma::ExceptionData.new(e, "Test Exception"))
          puts "Problem sending exception to Sfalma. Check your API key."
        else
          puts "Test Exception sent. Please login to http://www.sfalma.com to see it!"
        end
      end
    end
  end
end


