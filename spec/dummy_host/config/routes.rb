# frozen_string_literal: true

Rails.application.routes.draw do
  mount Dummy::Engine => "/dummy"
  Widget::Assets.draw(self, "/widget/assets")
end
