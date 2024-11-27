# frozen_string_literal: true

module Forms
  class WordImport
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :csv_file

    validates :csv_file, presence: true

    def self.model_name
      ActiveModel::Name.new(self, nil, "WordImport")
    end

    def csv
      CSV.read(csv_file.path, headers: true)
    end
  end
end
