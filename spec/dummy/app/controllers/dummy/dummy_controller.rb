# frozen_string_literal: true

module Dummy
  class DummyController < ActionController::Base
    def index
      render inline: <<~ERB, layout: false
        <!DOCTYPE html>
        <html>
        <head>
          <%= Dummy.stylesheet_link_tag "application" %>
          <%= Dummy.javascript_importmap_tags "application" %>
        </head>
        <body>
          <h1>Dummy Engine</h1>
          <%= Dummy.image_tag "logo.png", alt: "Logo" %>
        </body>
        </html>
      ERB
    end
  end
end
