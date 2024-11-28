# frozen_string_literal: true

class ReviewMailer < ApplicationMailer
  def discarded(new_word)
    @new_word = new_word

    mail to: ENV["REVIEW_EXCEPTION_MAIL"], subject: t(".subject", name: @new_word.name)
  end
end
