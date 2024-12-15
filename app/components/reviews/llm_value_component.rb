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
    word_attribute_edit.proposed_value
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
    Llm::Attributes.relation_klass(attribute_name)&.values
  end
end
