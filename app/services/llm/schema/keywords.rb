# frozen_string_literal: true

module Llm
  module Schema
    class Keywords < Base
      define_schema do
        property :keywords, T::Array[String], description: "Stichwörter zu diesem Wort"
      end
    end
  end
end
