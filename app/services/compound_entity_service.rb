# frozen_string_literal: true

class CompoundEntityService
  attr_reader :word

  def initialize(word)
    @word = word
  end

  def assign_compound_entities(compound_entity_ids)
    compound_entity_ids.map.with_index do |type_with_id, position|
      process_compound_entity(type_with_id, position)
    end.compact
  end

  private

  def process_compound_entity(type_with_id, position)
    type, id = type_with_id.split(":")

    if id.blank?
      find_existing_entity(type, position)
    else
      create_new_entity(type, id, position)
    end
  end

  def find_existing_entity(type, position)
    CompoundEntity.find_by(id: type)&.tap do |entity|
      entity.pos = position + 1
    end
  end

  def create_new_entity(type, id, position)
    return unless CompoundEntity::VALID_COMPOUND_TYPES.include?(type)

    part = type.constantize.find_by(id:)
    return if part.blank?

    CompoundEntity.find_or_initialize_by(word:, part:).tap do |entity|
      entity.pos = position + 1
    end
  end
end
