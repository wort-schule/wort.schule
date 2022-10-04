# frozen_string_literal: true

class UserProfileAttributesComponent < ViewComponent::Base
  include ComponentsHelper
  include HeroiconHelper

  def initialize(user:)
    @user = user
  end

  def own_user?
    @user == helpers.current_user
  end
end
