# frozen_string_literal: true

module Llm
  class Attributes
    class UnsupportedWordType < StandardError; end

    def self.all
      {
        noun: Llm::Schema::Noun.properties,
        verb: Llm::Schema::Verb.properties,
        adjective: Llm::Schema::Adjective.properties
      }
    end

    def self.keys_with_types
      collection.map { |(title, key)| key }
    end

    def self.collection
      all.each_with_object([]) do |(type, attributes), array|
        attributes.each do |attribute|
          array << [
            type.to_s.classify.constantize.human_attribute_name(attribute),
            "#{type}.#{attribute}"
          ]
        end
      end.uniq { |title, key| title }
    end

    def self.translate(attributes)
      attributes.map do |attribute_with_type|
        type, attribute = attribute_with_type.split(".")

        type.to_s.classify.constantize.human_attribute_name(attribute)
      end.uniq
    end

    def self.filter(response_model:, attribute_name:, value:)
      type = response_model.schema.dig(:properties, attribute_name.to_sym)&.type

      if type.is_a?(T::Types::TypedArray)
        if relation_klass(attribute_name).present?
          value.clamped(relation_klass(attribute_name).values)
        else
          value
        end
      else
        value
      end
    end

    def self.relation_klass(attribute_name)
      case attribute_name.to_s
      when "topics" then Topic
      when "strategies" then Strategy
      when "phenomenons" then Phenomenon
      when "compound_entities", "synonyms", "opposites", "keywords", "rimes" then Word
      end
    end

    def self.update!(word:, attribute_name:, value:)
      type = response_model(word.type).schema.dig(:properties, attribute_name.to_sym)&.type

      transformed_value = if type.is_a?(T::Types::TypedArray)
        case attribute_name.to_s
        when "topics"
          Topic.where(name: value)
        when "strategies"
          Strategy.where(name: value)
        when "phenomenons"
          Phenomenon.where(name: value)
        when "compound_entities", "synonyms", "opposites", "rimes"
          Word.where(name: value)
        when "keywords"
          listed_keywords = Word.where(name: value)
          unlisted_keywords = value - listed_keywords.pluck(:name)

          word.transaction do
            word.update!(attribute_name => listed_keywords)

            unlisted_keywords.each do |keyword|
              word_type = if keyword[0] == keyword[0].upcase
                "Noun"
              else
                (keyword.ends_with?("en") ? "Verb" : "Adjective")
              end

              word_import = WordImport.create!(
                name: keyword,
                topic: keyword,
                word_type:
              )
              UnlistedKeyword.create!(
                word:,
                word_import:
              )
            end
          end

          return
        end
      else
        value
      end

      word.update!(attribute_name => transformed_value)
    end

    def self.response_model(word_type)
      case word_type
      when "Noun" then Schema::Noun
      when "Verb" then Schema::Verb
      when "Adjective" then Schema::Adjective
      else raise UnsupportedWordType, "Word type '#{word_type}' is not supported for LLM enrichment"
      end
    end
  end
end
