# frozen_string_literal: true

require "rails"
require "action_controller/railtie"

# Add dummy engine's lib to load path
$LOAD_PATH.unshift File.expand_path("../../dummy/lib", __dir__)
require "dummy"

module DummyHost
  class Application < Rails::Application
    config.eager_load = false
    config.hosts.clear
    config.secret_key_base = "test_secret_key_base_for_testing_only"

    # Load routes from our routes file
    config.paths["config/routes.rb"] = File.expand_path("routes.rb", __dir__)
  end
end
