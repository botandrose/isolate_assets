# frozen_string_literal: true

require "digest/sha2"
require "active_support/core_ext/class/attribute"
require_relative "isolate_assets/version"

module IsolateAssets
  autoload :Assets, "isolate_assets/assets"
  autoload :Controller, "isolate_assets/controller"
  autoload :Helper, "isolate_assets/helper"
  autoload :EngineExtension, "isolate_assets/engine_extension"

  HELPER_METHODS = %i[
    stylesheet_link_tag javascript_include_tag javascript_importmap_tags
    asset_path image_path image_tag font_path audio_path audio_tag video_path video_tag
  ].freeze

  # Wires up an engine that draws its asset route into the application router
  # rather than mounting an isolated route set. Returns the Assets handle; draw
  # the route from the engine's routes file with `assets.draw(self, path)`.
  def self.register(namespace:, engine:, route_name:, assets_subdir: "assets")
    assets = Assets.new(
      engine: engine,
      assets_subdir: assets_subdir,
      route_name: route_name,
      url_helpers: -> { Rails.application.routes.url_helpers },
    )
    build_controller(assets)
    expose_helpers(namespace, assets)
    assets
  end

  def self.build_controller(assets)
    controller = Class.new(Controller)
    controller.isolated_assets = assets
    assets.controller = controller
    controller
  end

  # Defines isolated_assets + the asset tag helpers (stylesheet_link_tag, etc.)
  # as singleton methods on the given module, e.g. Dummy.stylesheet_link_tag.
  def self.expose_helpers(namespace, assets)
    helper_module = Module.new do
      define_method(:isolated_assets) { assets }
      include Helper
    end
    namespace.singleton_class.define_method(:isolated_assets) { assets }
    namespace.singleton_class.define_method(:isolated_assets_helper) { helper_module }

    helper_context = Class.new do
      include Helper
      define_method(:isolated_assets) { assets }
    end.new
    HELPER_METHODS.each do |method_name|
      namespace.singleton_class.define_method(method_name) do |*args, **kwargs, &block|
        helper_context.send(method_name, *args, **kwargs, &block)
      end
    end
    helper_module
  end
end

# Extend Rails::Engine with isolate_assets
Rails::Engine.extend(IsolateAssets::EngineExtension)
