# frozen_string_literal: true

module Llm
  module Schema
    class ExampleSentencesSuggestion < Base
      define_schema do
        property :example_sentences, T::Array[String], description: "3 kindgerechte Beispielsätze für Grundschulkinder (Klasse 1-4), die das Wort im Kontext zeigen"
        property :image_alt_text, String, description: "Kurzer Alternativtext für ein Bild zu diesem Wort (max 150 Zeichen), der beschreibt was auf einem typischen Bild zu sehen wäre"
      end
    end
  end
end
