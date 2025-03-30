# frozen_string_literal: true

module Forms
  class LlmEnrichmentList
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :list_id, :string
    attribute :user

    validates :list_id, presence: true
    validates :user, presence: true

    def save
      return false if invalid?

      EnrichWordListJob.perform_later(list_id)
    end

    def valid?(context = nil)
      super && list.present?
    end

    def list
      user.lists.find(list_id)
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "LlmEnrichment")
    end
  end
end
