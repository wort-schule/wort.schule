# frozen_string_literal: true

module Llm
  module Schema
    class Shared
      def self.properties
        <<~RUBY
          property :meaning, String, description: "Die Bedeutung dieses Wortes in einem kurzen Satz"
          property :meaning_long, String, description: "Die Bedeutung dieses Wortes in mehr als einem Satz"
          property :hierarchy, String, description: "Die Kategorie, in die dieses Wort am Besten passt"
          property :topics, T::Array[String], description: "Themen, die dieses Wort beschreiben"
          property :syllables, String, description: "Die gesprochenen Silben dieses Wortes getrennt mit einem '-'"
          property :written_syllables, String, description: "Die geschriebenen Silben dieses Wortes getrennt mit einem '-'"
          property :prototype, T::Boolean, description: "Ob dies ein Modellwort ist"
          property :foreign, T::Boolean, description: "Ob dies ein Fremdwort ist"
          property :compound, T::Boolean, description: "Ob dies ein zusammengesetztes Wort ist"
          property :prefix, String, description: "Vorsilbe dieses Wortes"
          property :postfix, String, description: "Endung dieses Wortes"
          property :strategies, T::Array[String], description: "Strategien, die auf dieses Wort passen"
          property :phenomenons, T::Array[String], description: "Phänomene, die dieses Wort verwendet"
          property :compound_entities, T::Array[String], description: "Bausteine dieses Wortes"
          property :synonyms, T::Array[String], description: "Synonyme dieses Wortes"
          property :opposites, T::Array[String], description: "Gegenteile dieses Wortes"
          property :rimes, T::Array[String], description: "Wörter, die mit diesem Wort reimen"
          property :example_sentences, T::Array[String], description: "Besipielsätze, die dieses Wort verwenden"
        RUBY
      end
    end
  end
end
