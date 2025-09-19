# frozen_string_literal: true

module Llm
  module Schema
    class FunctionWord < Base
      define_schema do
        property :syllables, String, description: "Die gesprochenen Silben dieses Wortes getrennt mit einem '-'"
        property :written_syllables, String, description: "Die geschriebenen Silben dieses Wortes getrennt mit einem '-'"
      end
    end
  end
end
