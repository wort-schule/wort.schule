# frozen_string_literal: true

module Llm
  module Schema
    class Base
      include EasyTalk::Model

      def self.from_word(word)
        serialized_attributes = properties.to_h do |property|
          values = word.send(property)

          values = values.map(&:name).sort if values.is_a?(ActiveRecord::Relation)
          values = values.name if values.is_a?(ActiveRecord::Base)

          [property, values]
        end

        new(serialized_attributes)
      end
    end
  end
end
