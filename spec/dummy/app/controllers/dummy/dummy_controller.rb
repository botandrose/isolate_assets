# frozen_string_literal: true

module Dummy
  class DummyController < ActionController::Base
    def index
      render inline: <<~ERB, layout: false
        <!DOCTYPE html>
        <html>
        <head>
          <%= engine_stylesheet_link_tag "application" %>
          <%= engine_javascript_importmap_tags "application" %>
        </head>
        <body>
          <h1>Dummy Engine</h1>
        </body>
        </html>
      ERB
    end
  end
end
