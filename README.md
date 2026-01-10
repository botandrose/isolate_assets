# EngineAssets

Self-contained asset serving for Rails engines. Serve JavaScript, CSS, and other assets from your engine without depending on Sprockets, Propshaft, or the host application's asset pipeline.

## Why?

Rails engines that include UI components need to serve assets, but integrating with the host app's asset pipeline is problematic:

- **Sprockets/Propshaft conflicts** - Different versions, configurations, or the host might not use them at all
- **Webpacker/esbuild/Vite** - Modern setups don't expect engine assets
- **Configuration burden** - Users must manually configure asset paths
- **Version compatibility** - Asset pipeline APIs change between Rails versions

EngineAssets solves this by letting your engine serve its own assets through a simple controller, with fingerprinting and caching handled automatically.

## Installation

Add to your engine's gemspec:

```ruby
spec.add_dependency "engine_assets"
```

## Usage

### 1. Set up your engine

In your engine file:

```ruby
# lib/my_engine/engine.rb
require "engine_assets"

module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    initializer "my_engine.assets", before: :set_routes_reloader do
      MyEngine.engine_assets = EngineAssets.new(engine: self)
    end
  end

  mattr_accessor :engine_assets
end
```

### 2. Add your assets

Place assets in `app/engine_assets/`:

```
my_engine/
  app/
    engine_assets/
      javascripts/
        application.js
        components/
          widget.js
      stylesheets/
        application.css
        theme.css
```

### 3. Include the helper

In your engine's application helper:

```ruby
# app/helpers/my_engine/application_helper.rb
module MyEngine
  module ApplicationHelper
    include MyEngine.engine_assets.helper
  end
end
```

### 4. Use in your views

```erb
<%# Basic stylesheet %>
<%= engine_stylesheet_link_tag "application" %>

<%# Basic script tag %>
<%= engine_javascript_include_tag "application" %>

<%# ES6 import maps with CDN dependencies %>
<%= engine_javascript_importmap_tags "application", {
  "jquery" => "https://cdn.jsdelivr.net/npm/jquery@3.7.1/+esm",
} %>

```
Example output:

```html
<script type="importmap">
{
  "imports": {
    "jquery": "https://cdn.jsdelivr.net/npm/jquery@3.7.1/+esm",
    "my_engine/application": "/my_engine/assets/application.js?v=a1b2c3d4",
    "my_engine/components/widget": "/my_engine/assets/components/widget.js?v=e5f6g7h8"
  }
}
</script>
<script type="module">
  import "my_engine/application"
</script>
```

## Requirements

- Ruby 3.2+
- Rails 7.2+

## License

MIT
