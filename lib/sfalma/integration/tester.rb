module Sfalma
  module Integration
    class SfalmaTestException <StandardError;
    end

    def self.test
      begin
        raise SfalmaTestException.new, 'Test exception from Rails'
      rescue Exception => e
        unless Sfalma::Remote.error(Sfalma::ExceptionData.new(e, "Test Exception"))
          puts "Problem sending exception to Sfalma. Check your API key."
        else
          puts "We got one! Head to http://www.sfalma.com/login to see the error!"
        end
      end
    end
  end
end


