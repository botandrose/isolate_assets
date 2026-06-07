# frozen_string_literal: true

module IsolateAssets
  module EngineExtension
    def isolate_assets(assets_subdir: "assets")
      engine_class = self

      # Exclude engine assets from host's asset pipeline (if one exists)
      initializer "#{engine_name}.isolate_assets.exclude_from_pipeline", before: :load_config_initializers do |app|
        next unless app.config.respond_to?(:assets) && app.config.assets

        asset_base = engine_class.root.join("app", assets_subdir)
        app.config.assets.excluded_paths ||= []
        if asset_base.exist?
          asset_base.children.select(&:directory?).each do |subdir|
            app.config.assets.excluded_paths << subdir.to_s
          end
        end
      end

      # Sprockets doesn't respect excluded_paths, so filter manually
      initializer "#{engine_name}.isolate_assets.filter_asset_paths", after: :load_config_initializers do |app|
        next unless app.config.respond_to?(:assets) && app.config.assets
        next unless app.config.assets.excluded_paths.present?

        excluded = app.config.assets.excluded_paths.map(&:to_s)
        app.config.assets.paths = app.config.assets.paths.reject do |path|
          excluded.include?(path.to_s)
        end
      end

      initializer "#{engine_name}.isolate_assets", before: :set_routes_reloader do
        assets = IsolateAssets::Assets.new(engine: engine_class, assets_subdir: assets_subdir)
        controller_class = IsolateAssets.build_controller(assets)

        if engine_class.respond_to?(:railtie_namespace) && engine_class.railtie_namespace
          IsolateAssets.expose_helpers(engine_class.railtie_namespace, assets)
        end

        engine_class.routes.prepend do
          get "/assets/*file", to: controller_class.action(:show), as: :isolated_asset
        end
      end
    end
  end
end
