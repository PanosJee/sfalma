$:.unshift File.dirname(__FILE__)
require 'exceptional/rails'
require 'exceptional/deployed_environment'
require 'exceptional/agent/worker'
require 'exceptional/exception_data'
require 'exceptional/version'
require 'rubygems'

require 'zlib'
require 'cgi'
require 'net/http'
require 'logger'
require 'yaml'
require 'json'

module Exceptional
  class LicenseException < StandardError; end
  class ConfigurationException < StandardError; end
  
  ::PROTOCOL_VERSION = 3
  # Defaults for configuration variables
  ::REMOTE_HOST = "getexceptional.com"
  ::REMOTE_PORT = 80
  ::REMOTE_SSL_PORT = 443
  ::SSL = false
  ::LOG_LEVEL = 'info'
  ::LOG_PATH = nil
  ::WORKER_TIMEOUT = 5 # seconds
  ::MODE = :direct
  
  class << self
    attr_accessor :api_key, :log, :deployed_environment, :log_path, :worker, 
                  :worker_thread, :environment, :application_root
    attr_writer   :remote_host, :remote_port, :ssl_enabled, :log_level
    
    def rescue(&block)
      begin
        block.call 
      rescue Exception => e
        self.catch(e)
        raise(e)
      end
    end 
    
    def parse(exception)
      exception_data = ExceptionData.new
      exception_data.exception_backtrace = exception.backtrace
      exception_data.exception_message = exception.message
      exception_data.exception_class = exception.class.to_s
      exception_data
    end
    
    def authenticate
      # No data required to authenticate, send a nil string? hacky
      return @authenticated if @authenticated
      authenticated = call_remote(:authenticate, "")
      @authenticated = authenticated =~ /true/
    end
    
    def post(exception_data)
      begin
        call_remote(:errors, exception_data.to_json)
      rescue
        
      end
    end
    
    def catch(exception)
      exception_data = parse(exception)
      post(exception_data)
    end
    
    def handle(exception, controller, request, params)
      log! "Handling #{exception.message}", 'info'
      e = parse(exception)
      # Additional data for Rails Exceptions
      e.framework = "rails"
      e.controller_name = controller.controller_name
      e.action_name = controller.action_name
      e.application_root = self.application_root
      e.occurred_at = Time.now.to_s
      e.environment = request.env.to_hash
      e.url "#{request.protocol}#{request.host}#{request.request_uri}"
       
      safe_session = {}
      request.session.instance_variables.each do |v|
        next if v =~ /db/
        # remove prepended @'s
        var = v.sub("@","")
        safe_session[var] = request.session.instance_variable_get(v)
      end
      
      e.session = safe_session
      e.parameters = params.to_hash

      if mode == :queue
        worker.add_exception(e)
      else # :direct mode
        post e
      end
    end
    
    def remote_host
      @remote_host || ::REMOTE_HOST
    end
    
    def remote_port
      @remote_port || default_port
    end
    
    def log_level
      @log_level || ::LOG_LEVEL
    end
    
    def mode
      deployed_environment ? deployed_environment.determine_mode : ::MODE
    end
    
    def default_port
      ssl_enabled? ? ::REMOTE_SSL_PORT : ::REMOTE_PORT  
    end
    
    def ssl_enabled?
      @ssl_enabled || ::SSL
    end
    
    def enabled?
      @enabled
    end
    
    def log!(msg, level = 'info')
      to_stderr msg
      log.send level, msg if log
    end
    
    def to_stderr(msg)
      STDERR.puts "** [Exceptional] " + msg 
    end
    
    def log_config_info
      log! "API Key: #{api_key}", 'debug'
      log! "Deployed Environment: #{deployed_environment.to_s}", 'debug'
      log! "Remote Host: #{remote_host}:#{remote_port}", 'debug'
      log! "Mode: #{mode}", 'debug'
      log! "Log level: #{log_level}", 'debug'
      log! "Log path: #{log_path}", 'debug'
    end
    
    def load_config(file)
      begin
        config = YAML::load(File.open(file))[self.environment]
        @api_key = config['api-key'] unless config['api-key'].nil?
        @ssl_enabled = config['ssl'] unless config['ssl'].nil?
        @log_level = config['log-level'] unless config['log-level'].nil?
        @enabled = config['enabled'] unless config['enabled'].nil?
        @remote_port = config['remote-port'].to_i unless config['remote-port'].nil?
        @remote_host = config['remote-host'] unless config['remote-host'].nil?
      rescue Exception => e
        raise ConfigurationException.new("Unable to load configuration file:#{file} for environment:#{environment}")
      end
    end
    
    protected 
    
    def valid_api_key?
      @api_key && @api_key.length == 40
    end

    
    def call_remote(method, data)
      if @api_key.nil?
        raise LicenseException.new("API Key must be configured") 
      end
      
      http = Net::HTTP.new(@remote_host, @remote_port) 
      uri = "/#{method.to_s}?&api_key=#{@api_key}&protocol_version=#{::PROTOCOL_VERSION}"
      # headers = { 'Content-Type' => 'text/x-json', 'Accept' => 'text/x-json' }
      headers = { 'Content-Type' => 'application/x-gzip', 'Accept' => 'application/x-gzip' }
      compressed_data = CGI::escape(Zlib::Deflate.deflate(data, Zlib::BEST_SPEED))
      response = http.start do |http|
        http.post(uri, compressed_data, headers) 
      end
      
      if response.kind_of? Net::HTTPSuccess
        return response.body
      else
        raise Exception.new("#{response.code}: #{response.message}")
      end 

    rescue Exception => e
      log! "Error contacting Exceptional: #{e}", 'info'
      log! e.backtrace.join("\n"), 'debug'
      raise e
    end
    
  end
  
end