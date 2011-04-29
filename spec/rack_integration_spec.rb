require File.dirname(__FILE__) + '/spec_helper'
require 'rack/mock'

class SfalmaTestError < StandardError
end

describe Rack::Sfalma do
    
  before(:each) do 
    Sfalma::Config.should_receive(:load)
    @error = SfalmaTestError.new
    @app = lambda { |env| raise @error, 'Whoops!' }
    @env = env = Rack::MockRequest.env_for("/foo")      
  end
  
  it 're-raises errors caught in the middleware' do       
    rr = Rack::Sfalma.new(@app)        
    Sfalma::Catcher.should_receive(:handle_with_rack)
    lambda { rr.call(@env)}.should raise_error(SfalmaTestError)    
  end
end