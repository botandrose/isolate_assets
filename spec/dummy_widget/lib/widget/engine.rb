# frozen_string_literal: true

require "isolate_assets"

module Widget
  # Deliberately NOT isolate_namespace'd: draws its asset route into the app router.
  class Engine < ::Rails::Engine
  end

  Assets = IsolateAssets.register(namespace: self, engine: Engine, route_name: :widget_asset)
end
