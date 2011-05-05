require File.dirname(__FILE__) + '/../spec_helper'

describe Sfalma::Config, 'defaults' do
  before :each do
    Sfalma::Config.reset
  end
  it "have sensible defaults" do
    Sfalma::Config.ssl?.should == false
    Sfalma::Config.remote_host.should == 'api.sfalma.com'
    Sfalma::Config.remote_port.should == 80
    Sfalma::Config.application_root.should == Dir.pwd
    Sfalma::Config.http_proxy_host.should be_nil
    Sfalma::Config.http_proxy_port.should be_nil
    Sfalma::Config.http_proxy_username.should be_nil
    Sfalma::Config.http_proxy_password.should be_nil
    Sfalma::Config.http_open_timeout.should == 2
    Sfalma::Config.http_read_timeout.should == 4
  end
  it "have correct defaults when ssl" do
    Sfalma::Config.ssl = true
    Sfalma::Config.remote_host.should == 'api.sfalma.com'
    Sfalma::Config.remote_port.should == 443
  end
  it "be disabled based on environment by default" do
    %w(development test).each do |env|
      Sfalma::Config.stub!(:application_environment).and_return(env)
      Sfalma::Config.should_send_to_api?.should == false
    end    
  end
  it "be enabled based on environment by default" do
    %w(production staging).each do |env|
      Sfalma::Config.stub!(:application_environment).and_return(env)
      Sfalma::Config.should_send_to_api?.should == true
    end
  end
  context 'production environment' do
    before :each do
      Sfalma::Config.stub!(:application_environment).and_return('production')
    end
    it "allow a new simpler format for " do
      Sfalma::Config.load('spec/fixtures/sfalma.yml')
      Sfalma::Config.api_key.should == 'abc123'
      Sfalma::Config.ssl?.should == true
      Sfalma::Config.remote_host.should == 'example.com'
      Sfalma::Config.remote_port.should == 123
      Sfalma::Config.should_send_to_api?.should == true
      Sfalma::Config.http_proxy_host.should == 'annoying-proxy.example.com'
      Sfalma::Config.http_proxy_port.should == 1066
      Sfalma::Config.http_proxy_username.should == 'bob'
      Sfalma::Config.http_proxy_password.should == 'jack'
      Sfalma::Config.http_open_timeout.should == 5
      Sfalma::Config.http_read_timeout.should == 10
    end
    it "allow disable production environment" do      
      Sfalma::Config.load('spec/fixtures/sfalma_disabled.yml')
      Sfalma::Config.api_key.should == 'abc123'
      Sfalma::Config.should_send_to_api?.should == false
    end
    it "load api_key from environment variable" do
      ENV.should_receive(:[]).with('SFALMA_API_KEY').any_number_of_times.and_return('98765')
      Sfalma::Config.api_key.should == '98765'
    end
  end
end