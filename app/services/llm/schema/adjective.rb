# frozen_string_literal: true

module Llm
  module Schema
    class Adjective
      include EasyTalk::Model

      define_schema do
        instance_eval(Llm::Schema::Shared.properties)

        property :comparative, String, description: "Komparativ dieses Adjektivs"
        property :superlative, String, description: "Superlativ dieses Adjektivs"
        property :absolute, T::Boolean, description: "Ob dies ein nicht steigerbares Adjektiv ist"
        property :irregular_comparison, T::Boolean, description: "Ob dieses Adjektiv unregelmässig steigerbar ist"
        property :irregular_declination, T::Boolean, description: "Ob dieses Adjektiv unregelmässig dekliniert wird"
      end
    end
  end
end
