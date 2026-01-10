# frozen_string_literal: true

RSpec.describe "Asset Pipeline Isolation" do
  describe "excluded_paths configuration" do
    let(:app) { Rails.application }
    let(:engine_asset_base) { Dummy::Engine.root.join("app/assets").to_s }

    it "adds engine asset subdirectories to excluded_paths" do
      excluded = app.config.assets.excluded_paths.map(&:to_s)
      expect(excluded).to include("#{engine_asset_base}/javascripts")
      expect(excluded).to include("#{engine_asset_base}/stylesheets")
    end

    it "removes engine asset paths from config.assets.paths" do
      # This is what dartsass-rails reads from
      asset_paths = app.config.assets.paths.map(&:to_s)
      # Engine asset subdirectories should not be in the paths
      expect(asset_paths.none? { |p| p.start_with?(engine_asset_base) }).to be true
    end

    it "engine assets are still accessible via isolate_assets route" do
      # Verify the engine route still works
      expect(Dummy.isolated_assets.asset_path("application", "js").to_s).to end_with("app/assets/javascripts/application.js")
    end
  end
end
