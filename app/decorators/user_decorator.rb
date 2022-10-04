# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate_all

  def avatar_url
    if object.avatar.attached?
      object.avatar.variant(:thumb)
    else
      Gravatar.src object.email
    end
  end

  def display_name
    full_name.presence || email
  end
end
