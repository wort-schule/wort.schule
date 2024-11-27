# frozen_string_literal: true

module Import
  class Csv
    attr_reader :csv

    def initialize(csv:)
      @csv = csv
    end

    def call
      success_count = 0

      csv.each do |row|
        word_type, name, topic = row[0..2]

        word_type = case word_type
        when "Nomen" then "Noun"
        when "Verb" then "Verb"
        when "Adjektiv" then "Adjective"
        when "Funktionswort" then "FunctionWord"
        else word_type
        end

        next if WordImport
          .where.not(state: :failed)
          .exists?(name:, topic:, word_type:)

        word_import = WordImport.create!(name:, topic:, word_type:, state: :new)
        ImportWordJob.perform_later(word_type:, name:, topic:, word_import_id: word_import.id)

        success_count += 1
      rescue => e
        word_import&.update!(state: :failed, error: e.full_message)
      end

      success_count
    end
  end
end
