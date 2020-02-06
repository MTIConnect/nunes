# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  def append_info_to_payload(payload)
    super
    payload[:tags] = { foo: 'bar' } if payload[:action] == 'index'
  end
end
