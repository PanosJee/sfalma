require 'ginger'

class ScenarioWithName < Ginger::Scenario
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

def is_ruby_19?
  RUBY_VERSION[0..2].eql?('1.9')
end

def create_scenario(version)
  scenario = ScenarioWithName.new("Rails #{version} on ruby: #{[RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_RELEASE_DATE, RUBY_PLATFORM].join(' ')}")
  scenario[/^active_?support$/]    = version
  scenario[/^active_?record$/]     = version
  scenario[/^action_?pack$/]       = version
  scenario[/^action_?controller$/] = version
  scenario[/^rails$/] = version
  scenario
end

Ginger.configure do |config|
  config.aliases["active_record"] = "activerecord"
  config.aliases["active_support"] = "activesupport"
  config.aliases["action_controller"] = "actionpack"

  config.scenarios << create_scenario("2.3.3")
  config.scenarios << create_scenario("2.3.4")
  config.scenarios << create_scenario("2.3.5")
  config.scenarios << create_scenario("3.0.3")
end