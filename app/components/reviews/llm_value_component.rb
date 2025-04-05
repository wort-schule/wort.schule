# frozen_string_literal: true

class Reviews::LlmValueComponent < ViewComponent::Base
  attr_reader :form

  def initialize(form:)
    @form = form
  end

  def word_attribute_edit
    form.object
  end

  def attribute_name
    word_attribute_edit.attribute_name
  end

  def word_type
    word_attribute_edit.word.type
  end

  def value
    values = word_attribute_edit.proposed_value

    if values.is_a?(Array)
      values.map do |element|
        if element.to_i.to_s == element.to_s
          word = Llm::Attributes.relation_klass(attribute_name).find(element)
          meaning = word.respond_to?(:meaning) ? word.meaning : nil
          text = meaning.present? ? "#{word.name} (#{meaning})" : word.name

          {value: element, text:}
        else
          {value: element, text: element}
        end
      end.to_json
    else
      values
    end
  end

  def type
    schema_type = Llm::Attributes
      .response_model(word_type)
      .schema
      .dig(:properties, attribute_name.to_sym)
      &.type

    if schema_type.is_a?(T::Types::TypedArray)
      :array
    elsif schema_type == T::Boolean
      :boolean
    else
      :string
    end
  end

  def collection
    Llm::Attributes.relation_klass(attribute_name)&.collection
  end
end
