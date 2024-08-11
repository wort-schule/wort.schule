# frozen_string_literal: true

class SlugConstraint
  def initialize(scope)
    @scope = scope
  end

  def matches?(request)
    word_match = request.original_fullpath.match(%r{/([^?/\.]+).*})
    word = word_match ? word_match[1] : nil

    word && @scope.pluck(:slug).include?(word)
  end
end
