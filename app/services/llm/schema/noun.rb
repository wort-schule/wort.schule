# frozen_string_literal: true

module Llm
  module Schema
    class Noun
      include EasyTalk::Model

      define_schema do
        property :meaning, String, description: "A description in German which explains this word"
        property :case_1_singular, String, description: "Deutsche Grundform dieses Wortes im Singular"
        property :case_1_plural, String, description: "Deutsche Deklination im Nominativ Plural"
        property :case_2_singular, String, description: "Deutsche Deklination im Genitiv Singular"
        property :case_2_plural, String, description: "Deutsche Deklination im Genitiv Plural"
        property :case_3_singular, String, description: "Deutsche Deklination im Dativ Singular"
        property :case_3_plural, String, description: "Deutsche Deklination im Dativ Plural"
        property :case_4_singular, String, description: "Deutsche Deklination im Akkusativ Singular"
        property :case_4_plural, String, description: "Deutsche Deklination im Akkusativ Plural"
      end
    end
  end
end
