require 'digest/md5'

module Sfalma
  class ApplicationEnvironment
    def self.to_hash(framework)
      env = extract_environment(ENV)
      {
        'client' => {
          'name' => Sfalma::CLIENT_NAME,
          'version' => Sfalma::VERSION,
          'protocol_version' => Sfalma::PROTOCOL_VERSION
        },
        'application_environment' => {
          'environment' => environment,
          'host' => get_hostname,
          'run_as_user' => get_username,
          'app_home' => (application_root.to_s.respond_to?(:force_encoding) ? application_root.to_s.force_encoding("UTF-8") : application_root),
          'gem_home' => env.fetch('GEM_HOME',''),
          'language' => 'ruby',
          'language_version' => language_version_string,
          'framework' => framework,
          'libraries_loaded' => libraries_loaded
        }
      }
    end
    
    def self.to_hash_basic(framework)
      {
        'client' => {
          'name' => Sfalma::CLIENT_NAME,
          'version' => Sfalma::VERSION,
          'protocol_version' => Sfalma::PROTOCOL_VERSION
        },
	      'application_environment' => {
	        'environment' => environment,
          'app_home' => (application_root.to_s.respond_to?(:force_encoding) ? application_root.to_s.force_encoding("UTF-8") : application_root),
          'gem_home' => extract_environment(ENV).fetch('GEM_HOME','')
	      }
      }
    end

    def self.environment
      Config.application_environment
    end

    def self.application_root
      Config.application_root
    end

    def self.extract_environment(env)
      env.reject do |k, v|
        (k =~ /^HTTP_/) || Sfalma::ENVIRONMENT_FILTER.include?(k)
      end
    end

    def self.get_hostname
      require 'socket' unless defined?(Socket)
      Socket.gethostname
    rescue
      'UNKNOWN'
    end

    def self.language_version_string
      "#{RUBY_VERSION rescue '?.?.?'} p#{RUBY_PATCHLEVEL rescue '???'} #{RUBY_RELEASE_DATE rescue '????-??-??'} #{RUBY_PLATFORM rescue '????'}"
    end

    def self.get_username
      ENV['LOGNAME'] || ENV['USER'] || ENV['USERNAME'] || ENV['APACHE_RUN_USER'] || 'UNKNOWN'
    end

    def self.libraries_loaded
      begin
        return Hash[*Gem.loaded_specs.map{|name, gem_specification| [name, gem_specification.version.to_s]}.flatten]
      rescue
      end
      {}
    end
  end
end
