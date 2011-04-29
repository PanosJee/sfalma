$:.unshift File.dirname(__FILE__)

require 'sfalma/monkeypatches'
require 'sfalma/catcher'
require 'sfalma/startup'
require 'sfalma/log_factory'
require 'sfalma/config'
require 'sfalma/application_environment'
require 'sfalma/exception_data'
require 'sfalma/controller_exception_data'
require 'sfalma/rack_exception_data'
require 'sfalma/alert_data'
require 'sfalma/remote'
require 'sfalma/integration/rack'    
require 'sfalma/integration/rack_rails'
require 'sfalma/integration/alerter'
require 'sfalma/version'
require 'sfalma/vcs'

require 'sfalma/railtie' if defined?(Rails::Railtie)

module Sfalma
  PROTOCOL_VERSION = 1
  CLIENT_NAME = 'sfalma-gem'
  ENVIRONMENT_FILTER = []

  def self.logger
    ::Sfalma::LogFactory.logger
  end

  def self.configure(api_key)
    Sfalma::Config.api_key = api_key
  end

  def self.handle(exception, name=nil)
    Sfalma::Catcher.handle(exception, name)
  end
  
  def self.rescue(name=nil, context=nil, &block)
    begin
      self.context(context) unless context.nil?
      block.call
    rescue Exception => e
      Sfalma::Catcher.handle(e,name)
    ensure
      self.clear!
    end
  end

  def self.rescue_and_reraise(name=nil, context=nil, &block)
    begin
      self.context(context) unless context.nil?
      block.call
    rescue Exception => e
      Sfalma::Catcher.handle(e,name)
      raise(e)
    ensure
      self.clear!      
    end
  end

  def self.clear!
    Thread.current[:sfalma_context] = nil
  end

  def self.context(hash = {})
    Thread.current[:sfalma_context] ||= {}
    Thread.current[:sfalma_context].merge!(hash)
    self
  end
end