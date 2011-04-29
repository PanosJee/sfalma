require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sfalma', 'integration', 'rails')

describe Sfalma do
  it "set the api key" do
    Sfalma.configure('api-key')
    Sfalma::Config.api_key.should == 'api-key'
  end
end