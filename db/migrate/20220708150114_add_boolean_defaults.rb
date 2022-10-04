class AddBooleanDefaults < ActiveRecord::Migration[7.0]
  def change
    change_column_default :adjectives, :absolute, from: nil, to: false
    change_column_default :adjectives, :irregular_declination, from: nil, to: false
    change_column_default :adjectives, :irregular_comparison, from: nil, to: false

    change_column_default :nouns, :pluraletantum, from: nil, to: false
    change_column_default :nouns, :singularetantum, from: nil, to: false

    change_column_default :prefixes, :separable, from: nil, to: false
    change_column_default :prefixes, :inseparable, from: nil, to: false

    change_column_default :verbs, :subjectless, from: nil, to: false
    change_column_default :verbs, :perfect_haben, from: nil, to: false
    change_column_default :verbs, :perfect_sein, from: nil, to: false
    change_column_default :verbs, :modal, from: nil, to: false
    change_column_default :verbs, :strong, from: nil, to: false

    change_column_default :words, :prototype, from: nil, to: false
    change_column_default :words, :foreign, from: nil, to: false
    change_column_default :words, :compound, from: nil, to: false

    change_column_null :adjectives, :absolute, false, false
    change_column_null :adjectives, :irregular_declination, false, false
    change_column_null :adjectives, :irregular_comparison, false, false

    change_column_null :nouns, :pluraletantum, false, false
    change_column_null :nouns, :singularetantum, false, false

    change_column_null :prefixes, :separable, false, false
    change_column_null :prefixes, :inseparable, false, false

    change_column_null :verbs, :subjectless, false, false
    change_column_null :verbs, :perfect_haben, false, false
    change_column_null :verbs, :perfect_sein, false, false
    change_column_null :verbs, :modal, false, false
    change_column_null :verbs, :strong, false, false

    change_column_null :words, :prototype, false, false
    change_column_null :words, :foreign, false, false
    change_column_null :words, :compound, false, false
  end
end
