# frozen_string_literal: true

class UserProfileThemeComponent < ViewComponent::Base
  include ComponentsHelper
  include HeroiconHelper

  attr_reader :user, :word_type, :list

  def initialize(user:, word_type:, list:)
    @user = user
    @word_type = word_type
    @list = list
  end
end
