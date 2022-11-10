# Monkey patch classes to get access to the data in the old tables
class NounTable < ApplicationRecord
  self.table_name = 'nouns'
end
class VerbTable < ApplicationRecord
  self.table_name = 'verbs'
end
class AdjectiveTable < ApplicationRecord
  self.table_name = 'adjectives'
end
class FunctionWordTable < ApplicationRecord
  self.table_name = 'function_words'
end

class ChangeMtiToSti < ActiveRecord::Migration[7.0]
  def change
    # This migration migrates from the current multiple table inheritance (MTI)
    # to a single table inheritance (STI). The main motivation for this change
    # is to allow friendly slugs across word types.
    #
    # Steps:
    #
    # 1. Add all attributes of nouns, verbs and adjectives to the `Words` table
    # 2. Add `type` attribute to distinguish word types for STI
    # 3. Delete the old tables

    # Noun attributes
    add_column :words, "plural", :string, default: ""
    add_column :words, "genus_id", :bigint
    add_column :words, "genus_masculine_id", :bigint
    add_column :words, "genus_feminine_id", :bigint
    add_column :words, "genus_neuter_id", :bigint
    add_column :words, "case_1_singular", :string, default: ""
    add_column :words, "case_1_plural", :string, default: ""
    add_column :words, "case_2_singular", :string, default: ""
    add_column :words, "case_2_plural", :string, default: ""
    add_column :words, "case_3_singular", :string, default: ""
    add_column :words, "case_3_plural", :string, default: ""
    add_column :words, "case_4_singular", :string, default: ""
    add_column :words, "case_4_plural", :string, default: ""
    add_column :words, "pluraletantum", :boolean, default: false, null: false
    add_column :words, "singularetantum", :boolean, default: false, null: false

    add_index :words, ["genus_feminine_id"], name: "index_words_on_genus_feminine_id"
    add_index :words, ["genus_id"], name: "index_words_on_genus_id"
    add_index :words, ["genus_masculine_id"], name: "index_words_on_genus_masculine_id"
    add_index :words, ["genus_neuter_id"], name: "index_words_on_genus_neuter_id"

    # Verb attributes
    add_column :words, "participle", :string, default: ""
    add_column :words, "past_participle", :string, default: ""
    add_column :words, "present_singular_1", :string, default: ""
    add_column :words, "present_singular_2", :string, default: ""
    add_column :words, "present_singular_3", :string, default: ""
    add_column :words, "present_plural_1", :string, default: ""
    add_column :words, "present_plural_2", :string, default: ""
    add_column :words, "present_plural_3", :string, default: ""
    add_column :words, "past_singular_1", :string, default: ""
    add_column :words, "past_singular_2", :string, default: ""
    add_column :words, "past_singular_3", :string, default: ""
    add_column :words, "past_plural_1", :string, default: ""
    add_column :words, "past_plural_2", :string, default: ""
    add_column :words, "past_plural_3", :string, default: ""
    add_column :words, "subjectless", :boolean, default: false, null: false
    add_column :words, "perfect_haben", :boolean, default: false, null: false
    add_column :words, "perfect_sein", :boolean, default: false, null: false
    add_column :words, "imperative_singular", :string
    add_column :words, "imperative_plural", :string
    add_column :words, "modal", :boolean, default: false, null: false
    add_column :words, "strong", :boolean, default: false, null: false

    # Adjective attributes
    add_column :words, "comparative", :string, default: ""
    add_column :words, "superlative", :string, default: ""
    add_column :words, "absolute", :boolean, default: false, null: false
    add_column :words, "irregular_declination", :boolean, default: false, null: false
    add_column :words, "irregular_comparison", :boolean, default: false, null: false

    # FunctionWord attributes
    add_column :words, "function_type", :integer

    # Common attributes
    add_column :words, "type", :string

    reversible do |change|
      change.up do
        Word.where(actable_type: 'Noun').find_each do |word|
          noun = NounTable.find(word.actable_id)

          word.update!(
            plural: noun.plural,
            genus_id: noun.genus_id,
            genus_masculine_id: noun.genus_masculine_id,
            genus_feminine_id: noun.genus_feminine_id,
            genus_neuter_id: noun.genus_neuter_id,
            case_1_singular: noun.case_1_singular,
            case_1_plural: noun.case_1_plural,
            case_2_singular: noun.case_2_singular,
            case_2_plural: noun.case_2_plural,
            case_3_singular: noun.case_3_singular,
            case_3_plural: noun.case_3_plural,
            case_4_singular: noun.case_4_singular,
            case_4_plural: noun.case_4_plural,
            pluraletantum: noun.pluraletantum,
            singularetantum: noun.singularetantum
          )
          ActiveRecord::Base.connection.execute("update words set type='Noun' where id=#{word.id}")
        end

        Word.where(actable_type: 'Verb').find_each do |word|
          verb = VerbTable.find(word.actable_id)

          word.update!(
            participle: verb.participle,
            past_participle: verb.past_participle,
            present_singular_1: verb.present_singular_1,
            present_singular_2: verb.present_singular_2,
            present_singular_3: verb.present_singular_3,
            present_plural_1: verb.present_plural_1,
            present_plural_2: verb.present_plural_2,
            present_plural_3: verb.present_plural_3,
            past_singular_1: verb.past_singular_1,
            past_singular_2: verb.past_singular_2,
            past_singular_3: verb.past_singular_3,
            past_plural_1: verb.past_plural_1,
            past_plural_2: verb.past_plural_2,
            past_plural_3: verb.past_plural_3,
            subjectless: verb.subjectless,
            perfect_haben: verb.perfect_haben,
            perfect_sein: verb.perfect_sein,
            imperative_singular: verb.imperative_singular,
            imperative_plural: verb.imperative_plural,
            modal: verb.modal,
            strong: verb.strong
          )
          ActiveRecord::Base.connection.execute("update words set type='Verb' where id=#{word.id}")
        end

        Word.where(actable_type: 'Adjective').find_each do |word|
          adjective = AdjectiveTable.find(word.actable_id)

          word.update!(
            comparative: adjective.comparative,
            superlative: adjective.superlative,
            absolute: adjective.absolute,
            irregular_declination: adjective.irregular_declination,
            irregular_comparison: adjective.irregular_comparison
          )
          ActiveRecord::Base.connection.execute("update words set type='Adjective' where id=#{word.id}")
        end

        Word.where(actable_type: 'FunctionWord').find_each do |word|
          function_word = FunctionWordTable.find(word.actable_id)

          word.update!(
            function_type: function_word.function_type
          )
          ActiveRecord::Base.connection.execute("update words set type='FunctionWord' where id=#{word.id}")
        end

        drop_table :nouns
        drop_table :verbs
        drop_table :adjectives
      end

      change_column_null :words, :type, false

      remove_column :words, :actable_type, :string
      remove_column :words, :actable_id, :bigint
    end
  end
end
