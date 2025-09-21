class UnlistedKeyword < ApplicationRecord
  extend Enumerize

  belongs_to :word, polymorphic: true
  belongs_to :word_import
  belongs_to :new_word, optional: true

  enumerize :state, in: %i[new processed]

  after_commit :import, on: :create

  scope :unprocessed, -> { where(state: "new") }

  private

  def import
    ImportWordJob.perform_later(
      word_type: word_import.word_type,
      name: word_import.name,
      topic: word_import.topic,
      word_import_id: word_import.id
    )
  end
end
