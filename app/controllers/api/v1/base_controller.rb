# frozen_string_literal: true

module Api
  module V1
    class BaseController < PublicController
      skip_forgery_protection

      before_action :set_json_format

      layout false

      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def not_found
        render json: {error: "not_found"}, status: :not_found
      end

      def set_json_format
        request.format = :json
      end
    end
  end
end
