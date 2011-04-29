require 'zlib'
require 'cgi'
require 'net/http'
require 'net/https'
require 'digest/md5'
require 'uri'

module Sfalma
  class Remote
    class << self
      def startup_announce(startup_data)
        data = startup_data.to_json
        #compressed = Zlib::Deflate.deflate(startup_data.to_json, Zlib::BEST_SPEED)
        hash_param = "&hash=#{Digest::MD5.new(data).hexdigest}"
        url = "/api/announcements?protocol_version=#{::Sfalma::PROTOCOL_VERSION}#{hash_param}"
        call_remote(url, data)
      end

      def error(exception_data)
        uniqueness_hash = exception_data.uniqueness_hash
      
        require 'net/http'
        require 'uri'
        #Net::HTTP.post_form(URI.parse('http://www.postbin.org/pelg4f'), {:data=> exception_data.to_json})
        
        hash_param = uniqueness_hash.nil? ? nil: "&hash=#{uniqueness_hash}"
        url = "/api/errors?protocol_version=#{::Sfalma::PROTOCOL_VERSION}#{hash_param}"
        compressed = exception_data.to_json#Zlib::Deflate.deflate(exception_data.to_json, Zlib::BEST_SPEED)
        #call_remote(url, compressed)
      end

      def call_remote(url, data)
        config = Sfalma::Config
        optional_proxy = Net::HTTP::Proxy(config.http_proxy_host,
                                          config.http_proxy_port,
                                          config.http_proxy_username,
                                          config.http_proxy_password)
        client = optional_proxy.new(config.remote_host, config.remote_port)

        client.open_timeout = config.http_open_timeout
        client.read_timeout = config.http_read_timeout
        client.use_ssl = config.ssl?
        client.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.ssl?
        begin
          headers = { "X-Sfalma-Api-Key" => ::Sfalma::Config.api_key }
          data.gsub!('&','@@@')
          response = client.post(url, "data=#{data}", headers)
          case response
            when Net::HTTPSuccess
              Sfalma.logger.info( "#{url} - #{response.message}")
              return true
            else
              Sfalma.logger.error("#{url} - #{response.code} - #{response.message}")
          end
        rescue Exception => e
          Sfalma.logger.error('Problem notifying Sfalma about the error')
          Sfalma.logger.error('You should better send us an email')
          Sfalma.logger.error(e)
        end
        nil
      end
    end
  end
end