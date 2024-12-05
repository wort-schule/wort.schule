module Langchain
  module LLM
    class Ollama < Base
      private

      def client
        @client ||= Faraday.new(url: url, headers: auth_headers, request: {timeout: 600, read_timeout: 600}) do |conn|
          conn.request :json
          conn.response :json
          conn.response :raise_error
          conn.response :logger, Langchain.logger, {headers: true, bodies: true, errors: true}
        end
      end
    end
  end
end
