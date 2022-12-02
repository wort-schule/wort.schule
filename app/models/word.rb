class Word < ApplicationRecord
  extend FriendlyId

  has_paper_trail

  include WordFilter

  VOWELS = "aeiouäöü"

  friendly_id :name, use: %i[sequentially_slugged finders]

  has_and_belongs_to_many :topics, -> { distinct }
  has_and_belongs_to_many :sources, -> { distinct }
  has_and_belongs_to_many :phenomenons, -> { distinct }
  has_and_belongs_to_many :strategies, -> { distinct }
  belongs_to :hierarchy, optional: true
  has_many :compound_entities
  has_and_belongs_to_many :keywords,
    -> { distinct.order(:name) },
    class_name: "Word",
    join_table: :keywords,
    foreign_key: :word_id,
    association_foreign_key: :keyword_id do
      def <<(group)
        group -= self if group.respond_to?(:to_a)
        super group unless include?(group)
      end
    end
  has_and_belongs_to_many :opposites,
    -> { distinct.order(:name) },
    class_name: "Word",
    join_table: :opposites,
    foreign_key: :word_id,
    association_foreign_key: :opposite_id do
      def <<(group)
        group -= self if group.respond_to?(:to_a)
        super group unless include?(group)
      end
    end
  has_and_belongs_to_many :synonyms,
    -> { distinct.order(:name) },
    class_name: "Word",
    join_table: :synonyms,
    foreign_key: :word_id,
    association_foreign_key: :synonym_id do
      def <<(group)
        group -= self if group.respond_to?(:to_a)
        super group unless include?(group)
      end
    end
  has_and_belongs_to_many :rimes,
    -> { distinct.order(:name) },
    class_name: "Word",
    join_table: :rimes,
    foreign_key: :word_id,
    association_foreign_key: :rime_id do
      def <<(group)
        group -= self if group.respond_to?(:to_a)
        super group unless include?(group)
      end
    end
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100], format: :png
    attachable.variant :open_graph, resize_to_fill: [1080, nil], format: :png
  end
  belongs_to :prefix, optional: true
  belongs_to :postfix, optional: true
  has_one :compound_entity, as: :part
  has_and_belongs_to_many :lists

  scope :ordered_lexigraphically, -> { order(:name) }

  before_save :set_consonant_vowel
  before_save :sanitize_slug
  before_save :sanitize_example_sentences

  validates :slug, presence: true, uniqueness: true

  ATTRIBUTES = [
    :name,
    :slug,
    :image,
    :meaning,
    :meaning_long,
    :hierarchy_id,
    :syllables,
    :written_syllables,
    :prototype,
    :foreign,
    :compound,
    :prefix_id,
    :postfix_id,
    topic_ids: [],
    strategy_ids: [],
    phenomenon_ids: [],
    compound_entities: [],
    synonym_ids: [],
    opposite_ids: [],
    keyword_ids: [],
    rime_ids: [],
    example_sentences: []
  ]

  def syllables_count
    syllables
      .split("-")
      .count(&:present?)
  end

  def assign_compound_entities(compound_entity_ids)
    self.compound_entities = compound_entity_ids.map.with_index do |type_with_id, position|
      type, id = type_with_id.split(":")

      if id.blank?
        CompoundEntity.find_by(id: type)&.tap do |entity|
          entity.pos = position + 1
        end
      else
        next unless CompoundEntity::VALID_COMPOUND_TYPES.include?(type)

        part = type.constantize.find_by(id:)
        next if part.blank?

        CompoundEntity.find_or_initialize_by(word: @noun, part:).tap do |entity|
          entity.pos = position + 1
        end
      end
    end.compact
  end

  def other_meanings_count
    Word.where("name ILIKE ?", name).count - 1
  end

  def accessible_lists(ability)
    List.accessible_by(ability).where(id: lists.pluck(:id))
  end

  private

  def set_consonant_vowel
    self.consonant_vowel = letters
      .join
      .gsub(/[#{VOWELS}]/o, "V")
      .gsub(/[^V]/, "K")
  end

  def letters
    name
      .downcase
      .gsub(/[^[:alpha:]]/, "")
      .chars
  end

  def sanitize_slug
    slug.downcase!
  end

  def sanitize_example_sentences
    example_sentences
      .map!(&:strip)
      .select!(&:present?)
  end
end
