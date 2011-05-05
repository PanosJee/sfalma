require 'rubygems'
require 'rack'

module Rack  
  class Sfalma    

    def initialize(app, api_key = nil)
      @app = app
      if api_key.nil?
        sfalma_config = "config/sfalma.yml"
        ::Sfalma::Config.load(sfalma_config)
      else
        ::Sfalma.configure(api_key)
        ::Sfalma::Config.enabled = true
        ::Sfalma.logger.info "Enabling Sfalma for Rack"
      end
    end    
    
    def call(env)
      begin
        status, headers, body =  @app.call(env)
      rescue Exception => e
        ::Sfalma::Catcher.handle_with_rack(e,env, Rack::Request.new(env))
        raise(e)
      end
    end
  end
end
