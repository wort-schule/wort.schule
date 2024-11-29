# frozen_string_literal: true

module Llm
  module Schema
    class Verb
      include EasyTalk::Model

      define_schema do
        instance_eval(Llm::Schema::Shared.properties)

        property :subjectless, T::Boolean, description: "Ob das Verb subjektlos ist"
        property :strong, T::Boolean, description: "Ob das Wort ein starkes Verb ist"
        property :imperative_singular, String, description: "Imperativ Singular dieses Verbs"
        property :imperative_plural, String, description: "Imperativ Plural dieses Verbs"
        property :participle, String, description: "Partizip dieses Verbs"
        property :past_participle, String, description: "Partizip dieses Verbs im Perfekt"
        property :perfect_haben, T::Boolean, description: "Ob das Verb im Perfekt mit haben gebildet wird"
        property :perfect_sein, T::Boolean, description: "Ob das Verb im Perfekt mit sein gebildet wird"

        property :present_singular_1, String, description: "Konjugation 1. Person Singular dieses Verbs in der Gegenwart"
        property :present_singular_2, String, description: "Konjugation 2. Person Singular dieses Verbs in der Gegenwart"
        property :present_singular_3, String, description: "Konjugation 3. Person Singular dieses Verbs in der Gegenwart"
        property :present_plural_1, String, description: "Konjugation 1. Person Plural dieses Verbs in der Gegenwart"
        property :present_plural_2, String, description: "Konjugation 2. Person Plural dieses Verbs in der Gegenwart"
        property :present_plural_3, String, description: "Konjugation 3. Person Plural dieses Verbs in der Gegenwart"

        property :past_singular_1, String, description: "Konjugation 1. Person Singular dieses Verbs in der Vergangenheit"
        property :past_singular_2, String, description: "Konjugation 2. Person Singular dieses Verbs in der Vergangenheit"
        property :past_singular_3, String, description: "Konjugation 3. Person Singular dieses Verbs in der Vergangenheit"
        property :past_plural_1, String, description: "Konjugation 1. Person Plural dieses Verbs in der Vergangenheit"
        property :past_plural_2, String, description: "Konjugation 2. Person Plural dieses Verbs in der Vergangenheit"
        property :past_plural_3, String, description: "Konjugation 3. Person Plural dieses Verbs in der Vergangenheit"
      end
    end
  end
end
