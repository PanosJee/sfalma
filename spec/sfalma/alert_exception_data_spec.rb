require File.dirname(__FILE__) + '/../spec_helper'

describe Sfalma::AlertData do
  it "raises error" do
    data = Sfalma::AlertData.new(Sfalma::Alert.new("A string"), "Alert")
    result_json = JSON.parse(data.to_json)
    result_json['rescue_block']['name'].should == 'Alert'
    result_json['sfalma']['message'].should == "A string"
    result_json['sfalma']['exception_class'] == 'Sfalma::Alert'
  end
end
