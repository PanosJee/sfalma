require File.dirname(__FILE__) + '/spec_helper'
require 'rack/mock'

class SfalmaTestError < StandardError
end

describe Rack::RailsExceptional do

  class TestingController < ActionController::Base
    filter_parameter_logging :password, /credit_card/

    def raises_something
      raise StandardError
    end
  end
    
  before(:each) do 
    @error = SfalmaTestError.new
    @app = lambda { |env| raise @error, 'Whoops!' }
    @env = Rack::MockRequest.env_for("/foo")    
    @env['action_controller.instance'] = TestingController.new    
  end
  
  it 're-raises errors caught in the middleware' do       
    rr = Rack::RailsSfalma.new(@app)
    Sfalma::Catcher.should_receive(:handle_with_controller)
    lambda { rr.call(@env)}.should raise_error(SfalmaTestError)    
  end
end