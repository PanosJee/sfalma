require File.dirname(__FILE__) + '/spec_helper'

context 'resuce errors from within a block' do
  class FunkyException < StandardError;
  end
  it "Sfalma.rescue should send to sfalma and swallow error " do
    to_raise = FunkyException.new
    Sfalma::Catcher.should_receive(:handle).with(to_raise, 'my rescue name')
    Sfalma.rescue('my rescue name') do
      raise to_raise
    end
  end

  it "reraises error with rescue_and_reraise" do
    to_raise = FunkyException.new
    Sfalma::Catcher.should_receive(:handle).with(to_raise, 'my rescue name')
    begin
      Sfalma.rescue_and_reraise('my rescue name') do
        raise to_raise
      end
      fail 'expected a reraise'
    rescue FunkyException => e
    end
  end

  it "Sfalma.handle calls Sfalma::Catcher.handle" do
    to_raise = FunkyException.new
    Sfalma::Catcher.should_receive(:handle).with(to_raise, 'optional name for where it has occurred')
    begin
      raise to_raise
    rescue => e
      Sfalma.handle(e, 'optional name for where it has occurred')
    end
  end

  it "collects context information but leaves thread local empty after block" do
    to_raise = FunkyException.new
    Sfalma::Config.should_receive(:should_send_to_api?).and_return(true)
    Sfalma::Remote.should_receive(:error) {|exception_data|
      exception_data.to_hash['context']['foo'] == 'bar'
      exception_data.to_hash['context']['baz'] == 42
      exception_data.to_hash['context']['cats'] == {'lol' => 'bot'}
    }
    Sfalma.rescue('my rescue name') do
      Sfalma.context('foo' => 'bar')
      Sfalma.context('baz' => 42)
      Sfalma.context('cats' => {'lol' => 'bot'})
      raise to_raise
    end
    Thread.current[:exceptional_context].should == nil
  end

  it "clearr context with Sfalma.context.clear!" do
    Sfalma.context('foo' => 'bar')
    Thread.current[:exceptional_context].should_not == nil
    Sfalma.context.clear!
    Thread.current[:exceptional_context].should == nil
  end

  it "allows optional second paramater hash to get added to context" do
    Sfalma.should_receive(:context).with(context_hash = {'foo' => 'bar', 'baz' => 42})
    Sfalma.rescue('my rescue', context_hash) {}
  end
  
  it "should clear context after every invocation" do
    Thread.current[:exceptional_context].should == nil

    Sfalma.rescue('my rescue', context_hash = {'foo' => 'bar', 'baz' => 42}) {
      Thread.current[:exceptional_context].should_not == nil      
    }
    
    Thread.current[:exceptional_context].should == nil        
  end
end