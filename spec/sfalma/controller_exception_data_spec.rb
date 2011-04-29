require File.dirname(__FILE__) + '/../spec_helper'
require 'digest/md5'


class Sfalma::FunkyError < StandardError
  def backtrace
    'backtrace'
  end
end

class BrokenJSON
  def to_json
    boom.time!
  end
end

describe Sfalma::ControllerExceptionData do
  it "raises useful error when to_json isn't available on to_hash" do
    request = ActionController::TestRequest.new
    brokenJson = BrokenJSON.new
    session = {:boom => brokenJson}
    request.stub!(:session).and_return(session)
    data = Sfalma::ControllerExceptionData.new(Sfalma::FunkyError.new, nil, request)
    JSON.parse(data.to_json)['request']['session']['data'].should == {"boom" => brokenJson.to_s}
  end
end
