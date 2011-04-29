require File.dirname(__FILE__) + '/../spec_helper'

describe Sfalma::Startup, 'announce_and_authenticate' do
  it "raise StartupException if api_key is nil" do
    Sfalma::Config.api_key = ''
    lambda { Sfalma::Startup.announce }.should raise_error(Sfalma::StartupException, /API Key/)
  end
  it "calls Remote announce" do
    Sfalma::Config.api_key = '123'
    Sfalma::Remote.should_receive(:startup_announce).with(hash_including({'client' => { 'name' => Sfalma::CLIENT_NAME,
                                                                                     'version' => Sfalma::VERSION,
                                                                                     'protocol_version' => Sfalma::PROTOCOL_VERSION}}))
    Sfalma::Startup.announce
  end
end