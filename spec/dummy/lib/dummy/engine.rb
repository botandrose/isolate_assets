# frozen_string_literal: true

require "engine_assets"

module Dummy
  class Engine < ::Rails::Engine
    isolate_namespace Dummy

    initializer "dummy.assets", before: :set_routes_reloader do
      Dummy.engine_assets = EngineAssets.new(engine: self)
    end
  end

  mattr_accessor :engine_assets
end
