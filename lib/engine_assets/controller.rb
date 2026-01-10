# frozen_string_literal: true

class EngineAssets
  class Controller < ActionController::API
    include ActionController::MimeResponds

    def show
      file_path = safe_file_path

      if file_path && File.exist?(file_path)
        expires_in 1.year, public: true
        fresh_when(etag: File.mtime(file_path), public: true)

        send_file file_path,
          type: content_type,
          disposition: "inline"
      else
        head :not_found
      end
    end

    private

    cattr_accessor :engine_assets

    def safe_file_path
      requested = params[:file].gsub("..", "")
      format = params[:format] || request.format.symbol.to_s
      engine_assets.asset_path(requested, format)
    end

    def content_type
      format = params[:format] || request.format.symbol.to_s
      engine_assets.content_type(format)
    end

    def verify_same_origin_request
    end
  end
end
