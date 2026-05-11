# frozen_string_literal: true

module Api
  module V1
    class WordsController < BaseController
      def index
        words = Word.ordered_lexigraphically

        words = words.where(type: params[:type]) if params[:type].present?
        words = words.where("words.name ILIKE ?", "%#{Word.replace_regex(params[:q])}%") if params[:q].present?
        words = words.joins(:topics).where(topics: {id: params[:topic_id]}) if params[:topic_id].present?

        if params[:with_image] == "true"
          words = words.joins(:image_attachment)
        end

        per_page = (params[:per_page] || 50).to_i.clamp(1, 200)
        @words = words.page(params[:page]).per(per_page)
        @total = words.count
      end

      def show
        @word = Word.friendly.find(params[:id])
      end

      def topics
        @topics = Topic.order(:name)
      end

      def hierarchies
        @hierarchies = Hierarchy.order(:name)
      end
    end
  end
end
