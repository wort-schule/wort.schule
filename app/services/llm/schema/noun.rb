# frozen_string_literal: true

module Llm
  module Schema
    class Noun
      include EasyTalk::Model

      define_schema do
        property :meaning, String, description: "A description in German which explains this word"
        property :case_1_plural, String, description: "German plural form of this word"
      end
    end
  end
end
