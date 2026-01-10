# frozen_string_literal: true

module Dummy
  module ApplicationHelper
    include Dummy.engine_assets.helper
  end
end
