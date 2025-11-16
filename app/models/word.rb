# Base class for German words using Single Table Inheritance (STI).
#
# Subclasses represent different word types:
# - Noun: German nouns with gender, plural forms, and case declensions
# - Verb: German verbs with conjugations and participles
# - Adjective: German adjectives with comparatives and superlatives
# - FunctionWord: Function words like articles, pronouns, conjunctions
#
# Common attributes include name, meaning, syllables, and associations with
# topics, sources, learning strategies, and other words (keywords, opposites, etc.)
class Word < ApplicationRecord
  extend FriendlyId

  has_paper_trail ignore: %i[hit_counter]

  include Collectable
  include HasStandardImage
  include SelfReferencingAssociations
  include WordFilter

  friendly_id :name, use: %i[sequentially_slugged finders]

  has_and_belongs_to_many :topics, -> { distinct }, counter_cache: :words_count
  has_and_belongs_to_many :sources, -> { distinct }, counter_cache: :words_count
  has_and_belongs_to_many :phenomenons, -> { distinct }, counter_cache: :words_count
  has_and_belongs_to_many :strategies, -> { distinct }, counter_cache: :words_count
  belongs_to :hierarchy, optional: true, counter_cache: :words_count
  has_many :compound_entities

  has_self_referential_association :keywords, :keyword_id
  has_self_referential_association :opposites, :opposite_id
  has_self_referential_association :synonyms, :synonym_id
  has_self_referential_association :rimes, :rime_id

  has_many_attached :audios

  belongs_to :prefix, optional: true
  belongs_to :postfix, optional: true
  has_one :compound_entity, as: :part
  has_and_belongs_to_many :lists, counter_cache: :words_count

  has_many :image_requests, dependent: :destroy

  scope :ordered_lexigraphically, -> { order(:name) }

  before_save :set_consonant_vowel
  before_save :sanitize_slug
  before_save :sanitize_example_sentences, if: -> { respond_to?(:example_sentences) }
  before_save :update_cologne_phonetics, if: -> { respond_to?(:cologne_phonetics) }

  after_save :handle_audio_attachments, if: -> { respond_to?(:with_tts) }
  after_save :delete_image_requests

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
    :with_tts,
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
    service = CompoundEntityService.new(self)
    self.compound_entities = service.assign_compound_entities(compound_entity_ids)
  end

  def other_meanings
    Word.where("name ILIKE ? AND id != ?", name, id)
  end

  def name_with_meaning
    if meaning.present?
      "#{name} (#{meaning})"
    elsif hierarchy.present?
      "#{name} (#{hierarchy.name})"
    else
      name
    end
  end

  def full_name
    name
  end

  def accessible_lists(ability)
    lists.accessible_by(ability)
  end

  def hit!(session, user_agent)
    return if DeviceDetector.new(user_agent).bot?

    session[:words_hit_counter] ||= {}
    last_hit = session[:words_hit_counter][id.to_s]

    return if last_hit.present? && DateTime.parse(last_hit) > 24.hours.ago

    increment!(:hit_counter)
    session[:words_hit_counter][id.to_s] = Time.zone.now.iso8601
  end

  delegate :slug_for_example_sentence, :audio_for_word, :audio_for_example_sentence,
    to: :audio_service

  private

  def audio_service
    @audio_service ||= WordAudioService.new(self)
  end

  def phonetics_service
    @phonetics_service ||= PhoneticsService.new(self)
  end

  def set_consonant_vowel
    self.consonant_vowel = phonetics_service.set_consonant_vowel_pattern
  end

  def sanitize_slug
    slug.downcase!
  end

  def sanitize_example_sentences
    return unless example_sentences.is_a? Array

    example_sentences
      .map!(&:strip)
      .select!(&:present?)
  end

  def cologne_phonetics_terms
    [name]
  end

  def update_cologne_phonetics
    self.cologne_phonetics = phonetics_service.update_cologne_phonetics
  end

  def handle_audio_attachments
    audio_service.handle_audio_attachments
  end

  def delete_image_requests
    return unless image.attached?

    ImageRequest
      .where(word: self)
      .delete_all
  end
end
