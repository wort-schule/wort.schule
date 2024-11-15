# frozen_string_literal: true

module Llm
  class Attributes
    def self.all
      {
        noun: Llm::Schema::Noun.properties
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
  end
end
