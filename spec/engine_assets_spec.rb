# frozen_string_literal: true

RSpec.describe EngineAssets do
  subject(:engine_assets) { Dummy.engine_assets }

  describe "VERSION" do
    it "has a version number" do
      expect(EngineAssets::VERSION).not_to be_nil
    end
  end

  describe "#asset_path" do
    it "returns path for JavaScript files" do
      path = engine_assets.asset_path("application", "js")
      expect(path.to_s).to end_with("app/engine_assets/javascripts/application.js")
    end

    it "returns path for CSS files" do
      path = engine_assets.asset_path("application", "css")
      expect(path.to_s).to end_with("app/engine_assets/stylesheets/application.css")
    end

    it "handles 'javascript' type alias" do
      path = engine_assets.asset_path("application", "javascript")
      expect(path.to_s).to end_with("app/engine_assets/javascripts/application.js")
    end

    it "handles 'stylesheet' type alias" do
      path = engine_assets.asset_path("application", "stylesheet")
      expect(path.to_s).to end_with("app/engine_assets/stylesheets/application.css")
    end
  end

  describe "#fingerprint" do
    it "returns an 8-character hex string for existing files" do
      fingerprint = engine_assets.fingerprint("application", "js")
      expect(fingerprint).to match(/\A[a-f0-9]{8}\z/)
    end

    it "returns 'missing' for non-existent files" do
      fingerprint = engine_assets.fingerprint("nonexistent", "js")
      expect(fingerprint).to eq("missing")
    end

    it "returns different fingerprints for different files" do
      js_fingerprint = engine_assets.fingerprint("application", "js")
      css_fingerprint = engine_assets.fingerprint("application", "css")
      expect(js_fingerprint).not_to eq(css_fingerprint)
    end
  end

  describe "#content_type" do
    it "returns application/javascript for js" do
      expect(engine_assets.content_type("js")).to eq("application/javascript")
    end

    it "returns application/javascript for javascript" do
      expect(engine_assets.content_type("javascript")).to eq("application/javascript")
    end

    it "returns text/css for css" do
      expect(engine_assets.content_type("css")).to eq("text/css")
    end

    it "returns text/css for stylesheet" do
      expect(engine_assets.content_type("stylesheet")).to eq("text/css")
    end

    it "returns application/octet-stream for unknown types" do
      expect(engine_assets.content_type("unknown")).to eq("application/octet-stream")
    end
  end

  describe "#javascript_files" do
    it "returns an array of JavaScript file paths" do
      files = engine_assets.javascript_files
      expect(files).to be_an(Array)
      expect(files.first.to_s).to end_with(".js")
    end
  end

  describe "#asset_url" do
    it "includes fingerprint as query parameter" do
      url = engine_assets.asset_url("application", "js")
      expect(url).to match(%r{/assets/application\.js\?v=[a-f0-9]{8}})
    end
  end

  describe "#helper" do
    it "returns a module that can be included" do
      helper = engine_assets.helper
      expect(helper).to be_a(Module)
    end
  end
end
