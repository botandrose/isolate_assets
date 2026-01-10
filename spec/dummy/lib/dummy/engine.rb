# frozen_string_literal: true

require "isolate_assets"

module Dummy
  class Engine < ::Rails::Engine
    isolate_namespace Dummy
    isolate_assets
  end
end
