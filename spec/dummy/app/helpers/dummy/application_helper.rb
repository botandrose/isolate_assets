# frozen_string_literal: true

module Dummy
  module ApplicationHelper
    include Dummy.isolated_assets_helper
  end
end
