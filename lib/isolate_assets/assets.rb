# frozen_string_literal: true

module IsolateAssets
  class Assets
    attr_reader :engine, :assets_subdir

    def initialize(engine:, assets_subdir: "assets")
      @engine = engine
      @assets_subdir = assets_subdir
      @fingerprints = {}
    end

    def asset_path(source, type)
      case type.to_s
      when "js", "javascript"
        engine.root.join("app/#{assets_subdir}/javascripts", "#{source}.js")
      when "css", "stylesheet"
        engine.root.join("app/#{assets_subdir}/stylesheets", "#{source}.css")
      end
    end

    def asset_url(source, type)
      fingerprint_value = fingerprint(source, type)
      engine.routes.url_helpers.isolated_asset_path("#{source}.#{normalize_type(type)}", v: fingerprint_value)
    end

    def fingerprint(source, type)
      cache_key = "#{source}.#{type}"

      if ::Rails.env.production?
        @fingerprints[cache_key] ||= calculate_fingerprint(source, type)
      else
        calculate_fingerprint(source, type)
      end
    end

    def content_type(type)
      case type.to_s
      when "js", "javascript"
        "application/javascript"
      when "css", "stylesheet"
        "text/css"
      else
        "application/octet-stream"
      end
    end

    def javascript_files
      engine.root.glob("app/#{assets_subdir}/javascripts/**/*.js")
    end

    private

    def normalize_type(type)
      case type.to_s
      when "javascript" then "js"
      when "stylesheet" then "css"
      else type.to_s
      end
    end

    def calculate_fingerprint(source, type)
      file_path = asset_path(source, type)

      if file_path && File.exist?(file_path)
        Digest::SHA256.file(file_path).hexdigest[0...8]
      else
        "missing"
      end
    end
  end
end
