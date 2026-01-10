# frozen_string_literal: true

RSpec.describe IsolateAssets do
  describe "VERSION" do
    it "has a version number" do
      expect(IsolateAssets::VERSION).not_to be_nil
    end
  end

  describe "isolate_assets class method" do
    it "is available on Rails::Engine" do
      expect(Rails::Engine).to respond_to(:isolate_assets)
    end
  end

  describe "Dummy.isolated_assets" do
    subject(:isolated_assets) { Dummy.isolated_assets }

    it "is accessible on the engine namespace" do
      expect(Dummy).to respond_to(:isolated_assets)
    end

    it "is an IsolateAssets::Assets instance" do
      expect(isolated_assets).to be_a(IsolateAssets::Assets)
    end

    describe "#asset_path" do
      it "returns path for JavaScript files" do
        path = isolated_assets.asset_path("application", "js")
        expect(path.to_s).to end_with("app/assets/javascripts/application.js")
      end

      it "returns path for CSS files" do
        path = isolated_assets.asset_path("application", "css")
        expect(path.to_s).to end_with("app/assets/stylesheets/application.css")
      end

      it "handles 'javascript' type alias" do
        path = isolated_assets.asset_path("application", "javascript")
        expect(path.to_s).to end_with("app/assets/javascripts/application.js")
      end

      it "handles 'stylesheet' type alias" do
        path = isolated_assets.asset_path("application", "stylesheet")
        expect(path.to_s).to end_with("app/assets/stylesheets/application.css")
      end

      it "returns path for image files" do
        path = isolated_assets.asset_path("logo", "png")
        expect(path.to_s).to end_with("app/assets/images/logo.png")
      end

      it "returns nil for unknown types" do
        path = isolated_assets.asset_path("file", "xyz")
        expect(path).to be_nil
      end
    end

    describe "#fingerprint" do
      it "returns an 8-character hex string for existing files" do
        fingerprint = isolated_assets.fingerprint("application", "js")
        expect(fingerprint).to match(/\A[a-f0-9]{8}\z/)
      end

      it "returns 'missing' for non-existent files" do
        fingerprint = isolated_assets.fingerprint("nonexistent", "js")
        expect(fingerprint).to eq("missing")
      end

      it "returns different fingerprints for different files" do
        js_fingerprint = isolated_assets.fingerprint("application", "js")
        css_fingerprint = isolated_assets.fingerprint("application", "css")
        expect(js_fingerprint).not_to eq(css_fingerprint)
      end

      it "returns fingerprint for image files" do
        fingerprint = isolated_assets.fingerprint("logo", "png")
        expect(fingerprint).to match(/\A[a-f0-9]{8}\z/)
      end
    end

    describe "#content_type" do
      it "returns application/javascript for js" do
        expect(isolated_assets.content_type("js")).to eq("application/javascript")
      end

      it "returns application/javascript for javascript" do
        expect(isolated_assets.content_type("javascript")).to eq("application/javascript")
      end

      it "returns text/css for css" do
        expect(isolated_assets.content_type("css")).to eq("text/css")
      end

      it "returns text/css for stylesheet" do
        expect(isolated_assets.content_type("stylesheet")).to eq("text/css")
      end

      it "returns image/png for png" do
        expect(isolated_assets.content_type("png")).to eq("image/png")
      end

      it "returns image/svg+xml for svg" do
        expect(isolated_assets.content_type("svg")).to eq("image/svg+xml")
      end

      it "returns font/woff2 for woff2" do
        expect(isolated_assets.content_type("woff2")).to eq("font/woff2")
      end

      it "returns application/octet-stream for unknown types" do
        expect(isolated_assets.content_type("unknown")).to eq("application/octet-stream")
      end
    end

    describe "#javascript_files" do
      it "returns an array of JavaScript file paths" do
        files = isolated_assets.javascript_files
        expect(files).to be_an(Array)
        expect(files.first.to_s).to end_with(".js")
      end
    end

    describe "#asset_url" do
      it "includes fingerprint as query parameter for js" do
        url = isolated_assets.asset_url("application", "js")
        expect(url).to match(%r{/assets/application\.js\?v=[a-f0-9]{8}})
      end

      it "includes fingerprint as query parameter for images" do
        url = isolated_assets.asset_url("logo", "png")
        expect(url).to match(%r{/assets/logo\.png\?v=[a-f0-9]{8}})
      end
    end
  end

  describe "Dummy.isolated_assets_helper" do
    it "is accessible on the engine namespace" do
      expect(Dummy).to respond_to(:isolated_assets_helper)
    end

    it "returns a module that can be included" do
      expect(Dummy.isolated_assets_helper).to be_a(Module)
    end
  end

  describe "namespaced helper methods" do
    describe "Dummy.stylesheet_link_tag" do
      it "generates a link tag with fingerprint" do
        result = Dummy.stylesheet_link_tag("application")
        expect(result).to include("<link")
        expect(result).to include('rel="stylesheet"')
        expect(result).to include("/assets/application.css?v=")
      end
    end

    describe "Dummy.javascript_include_tag" do
      it "generates a script tag with fingerprint" do
        result = Dummy.javascript_include_tag("application")
        expect(result).to include("<script")
        expect(result).to include("/assets/application.js?v=")
      end
    end

    describe "Dummy.image_tag" do
      it "generates an img tag with fingerprint" do
        result = Dummy.image_tag("logo.png", alt: "Logo")
        expect(result).to include("<img")
        expect(result).to include("/assets/logo.png?v=")
        expect(result).to include('alt="Logo"')
      end
    end

    describe "Dummy.image_path" do
      it "returns path with fingerprint" do
        result = Dummy.image_path("logo.png")
        expect(result).to match(%r{/assets/logo\.png\?v=[a-f0-9]{8}})
      end
    end

    describe "Dummy.asset_path" do
      it "returns path for any asset type" do
        result = Dummy.asset_path("logo.png")
        expect(result).to match(%r{/assets/logo\.png\?v=[a-f0-9]{8}})
      end
    end

    describe "Dummy.font_path" do
      it "returns path for font files" do
        result = Dummy.font_path("custom.woff2")
        expect(result).to match(%r{/assets/custom\.woff2\?v=})
      end
    end

    describe "Dummy.audio_path" do
      it "returns path for audio files" do
        result = Dummy.audio_path("sound.mp3")
        expect(result).to match(%r{/assets/sound\.mp3\?v=})
      end
    end

    describe "Dummy.video_path" do
      it "returns path for video files" do
        result = Dummy.video_path("clip.mp4")
        expect(result).to match(%r{/assets/clip\.mp4\?v=})
      end
    end
  end
end
