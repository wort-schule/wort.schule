# frozen_string_literal: true

module Llm
  module Schema
    class BaseForm
      include EasyTalk::Model

      define_schema do
        property :base_form, String, description: "The base form of the word in German"
        property :topic, String, description: "A broader topic in German this word belongs to. For example, for 'Katze' the topic would be 'Tiere'"
      end
    end
  end
end
