module Sfalma
  class Alert <StandardError;
  end

  module Integration
    def self.alert(msg, env={})
      return Sfalma::Remote.error(Sfalma::AlertData.new(Alert.new(msg), "Alert"))
    end
  end
end

