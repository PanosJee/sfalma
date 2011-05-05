require 'digest/md5'
require 'time'

module Sfalma
  class ExceptionData 
    
    def initialize(exception, name=nil)
      @exception = exception
      @name = name
    end

    def to_hash
      # Do not send the environment for every exception
      hash = ::Sfalma::ApplicationEnvironment.to_hash_basic(framework)
      app_home = hash['application_environment']['app_home']
      gem_home = hash['application_environment']['gem_home']
      line_and_number = where(@exception.backtrace, app_home, gem_home)
      
      hash.merge!({
        'exception' => {
          'klass' => @exception.class.to_s,
          'message' => @exception.message,
          'backtrace' => normalize(@exception.backtrace, app_home, gem_home),
          'occurred_at' => Time.now.utc.iso8601,
          'where' => line_and_number
        }
      })
      hash.merge!(extra_stuff)
      hash.merge!(context_stuff)
      #hash.merge!(::Sfalma::VCS(line_and_number, app_home).to_hash)
      self.class.sanitize_hash(hash)
    end
    
    def normalize(trace, app_home, gem_home)
      trace.map do |line|
        if !line.index(app_home).nil?
          line.gsub!(app_home,'[APP_HOME]')
        elsif !line.index(gem_home).nil?
          line.gsub!(gem_home, '[GEM_HOME]')
        end
        line
      end
    end
    
    def where(trace, app_path, gem_path)
      line_and_number = ''
      trace.each do |line|
        if !line.index(app_path).nil?
          line_and_number = line[0,line.rindex(':')]
          puts line
          break
        end
      end
      if line_and_number == ''
        line_and_number = trace[0][0,trace[0].rindex(':')]
      end
      line_and_number.gsub!(app_path,'').gsub!(gem_path,'') rescue line_and_number
      line_and_number
    end

    def extra_stuff
      { 'rescue_block' => { 'name' => @name} }
    end

    def context_stuff
      context = Thread.current[:exceptional_context]
      (context.nil? || context.empty?) ? {} : {'context' => context}
    end

    def to_json
      begin
        to_hash.to_json
      rescue NoMethodError
        begin
          require 'json'
          return to_hash.to_json
        rescue StandardError => e                   
          Sfalma.logger.error(e.message)
          Sfalma.logger.error(e.backtrace)                    
          raise StandardError.new("You need a json gem/library installed to send errors to Sfalma (Object.to_json not defined). \nInstall json_pure, yajl-ruby, json-jruby, or the c-based json gem")
        end
      end
    end
    
    def framework
      nil
    end    

    def uniqueness_hash
      return nil if (@exception.backtrace.nil? || @exception.backtrace.empty?)
      # in case we have the same exception class at the same line but caused by different method
      @exception.backtrace.push(@exception.message)
      traces = @exception.backtrace.collect{ |line| 
        line if line.scan(/_run__\d+__process_action__\d+__callbacks/).size<1 
      }.compact
      Digest::MD5.hexdigest(traces.join)
    end

    def self.sanitize_hash(hash)
      case hash
        when Hash
          hash.inject({}) do |result, (key, value)|            
            result.update(key => sanitize_hash(value))
          end
        when Array
          hash.collect{|value| sanitize_hash(value)}
        when Fixnum, String, Bignum
          hash
        else
          hash.to_s
      end
    rescue Exception => e
      Sfalma.logger.error(hash)
      Sfalma.logger.error(e.message)
      Sfalma.logger.error(e.backtrace)      
      {}
    end

    def extract_http_headers(env)
      headers = {}
      env.select{|k, v| k =~ /^HTTP_/}.each do |name, value|
        proper_name = name.sub(/^HTTP_/, '').split('_').map{|upper_case| upper_case.capitalize}.join('-')
        headers[proper_name] = value
      end
      unless headers['Cookie'].nil?
        headers['Cookie'] = headers['Cookie'].sub(/_session=\S+/, '_session=[FILTERED]')
      end
      headers
    end  
  
    def self.sanitize_session(request)
      session_hash = {'session_id' => "", 'data' => {}}

      if request.respond_to?(:session)      
        session = request.session
        session_hash['session_id'] = request.session_options ? request.session_options[:id] : nil
        session_hash['session_id'] ||= session.respond_to?(:session_id) ? session.session_id : session.instance_variable_get("@session_id")
        session_hash['data'] = session.respond_to?(:to_hash) ? session.to_hash : session.instance_variable_get("@data") || {}
        session_hash['session_id'] ||= session_hash['data'][:session_id]
        session_hash['data'].delete(:session_id)
      end

      self.sanitize_hash(session_hash)
    end  
  end
end