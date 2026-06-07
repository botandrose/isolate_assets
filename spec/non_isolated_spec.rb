# frozen_string_literal: true

RSpec.describe "non-isolated engine via IsolateAssets.register" do
  describe "Widget.isolated_assets" do
    it "is an IsolateAssets::Assets configured for the app route" do
      expect(Widget.isolated_assets).to be_a(IsolateAssets::Assets)
      expect(Widget.isolated_assets.route_name).to eq(:widget_asset)
    end
  end

  describe "namespaced helpers resolve to the app-router path" do
    it "Widget.stylesheet_link_tag links a fingerprinted css url" do
      html = Widget.stylesheet_link_tag("widget")
      expect(html).to include("<link")
      expect(html).to match(%r{href="/widget/assets/widget\.css\?v=[a-f0-9]{8}"})
    end

    it "Widget.javascript_include_tag passes options through" do
      html = Widget.javascript_include_tag("widget", type: "module")
      expect(html).to match(%r{src="/widget/assets/widget\.js\?v=[a-f0-9]{8}"})
      expect(html).to include('type="module"')
    end
  end

  describe "serving" do
    let(:client) { ActionDispatch::Integration::Session.new(Rails.application) }

    it "serves the asset with long-lived public cache headers" do
      fingerprint = Widget.isolated_assets.fingerprint("widget", "css")
      client.get "/widget/assets/widget.css?v=#{fingerprint}"

      expect(client.response.status).to eq(200)
      expect(client.response.content_type).to include("text/css")
      expect(client.response.headers["Cache-Control"]).to include("public")
      expect(client.response.body).to include("rebeccapurple")
    end

    it "404s for an unknown asset" do
      client.get "/widget/assets/nope.css"
      expect(client.response.status).to eq(404)
    end
  end
end
