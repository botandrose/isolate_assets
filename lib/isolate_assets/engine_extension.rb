# frozen_string_literal: true

module IsolateAssets
  module EngineExtension
    def isolate_assets(assets_subdir: "engine_assets")
      engine_class = self

      # Create a unique controller class for this engine
      controller_class = Class.new(IsolateAssets::Controller)

      # Register an initializer to set up assets when Rails boots
      initializer "#{engine_name}.isolate_assets", before: :set_routes_reloader do
        assets = IsolateAssets::Assets.new(engine: engine_class, assets_subdir: assets_subdir)

        # Create a unique helper module for this engine with the assets baked in
        helper_module = Module.new do
          define_method(:isolated_assets) { assets }
          include IsolateAssets::Helper
        end

        # Wire up the controller
        controller_class.isolated_assets = assets

        # Store on the engine's namespace module
        if engine_class.respond_to?(:railtie_namespace) && engine_class.railtie_namespace
          engine_class.railtie_namespace.singleton_class.define_method(:isolated_assets) { assets }
          engine_class.railtie_namespace.singleton_class.define_method(:isolated_assets_helper) { helper_module }
        end

        # Draw routes
        engine_class.routes.prepend do
          get "/assets/*file", to: controller_class.action(:show), as: :isolated_asset
        end
      end
    end
  end
end
