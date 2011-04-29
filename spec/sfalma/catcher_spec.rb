require File.dirname(__FILE__) + '/../spec_helper'

describe Sfalma::Catcher do
  it "should create exception_data object and send json to the api" do
    Sfalma::Config.should_receive(:should_send_to_api?).and_return(true)
    exception = mock('exception')
    controller = mock('controller')
    request = mock('request')
    Sfalma::ControllerExceptionData.should_receive(:new).with(exception,controller,request).and_return(data = mock('exception_data'))
    Sfalma::Remote.should_receive(:error).with(data)
    Sfalma::Catcher.handle_with_controller(exception,controller,request)
  end
end