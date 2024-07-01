# frozen_string_literal: true

class WordTypes
  NAMES = [
    {
      key: "default",
      names: {
        "Noun" => ["Nomen", "Nomen"],
        "Verb" => ["Verb", "Verben"],
        "Adjective" => ["Adjektiv", "Adjektive"],
        "FunctionWord" => ["Funktionswort", "Funktionswörter"]
      }
    },
    {
      key: "sub",
      names: {
        "Noun" => ["Substantiv", "Substantive"],
        "Verb" => ["Verb", "Verben"],
        "Adjective" => ["Adjektiv", "Adjektive"],
        "FunctionWord" => ["Funktionswort", "Funktionswörter"]
      }
    },
    {
      key: "german",
      names: {
        "Noun" => ["Namenwort", "Namenwörter"],
        "Verb" => ["Tu-Wort", "Tu-Wörter"],
        "Adjective" => ["Wie-Wort", "Wie-Wörter"],
        "FunctionWord" => ["kleines Wort", "kleine Wörter"]
      }
    }
  ].freeze

  def self.label(key, word_type, plural: false)
    NAMES
      .find { |names| names[:key] == key }
      &.dig(:names, word_type, plural ? 1 : 0)
  end

  def self.keys
    as_collection.map(&:second)
  end

  def self.as_collection
    NAMES
      .map do |config|
        key = config[:key]
        label = config[:names].values.map(&:first).join(" — ")

        [label, key]
      end
  end

  def self.label_all(key)
    config = NAMES.find { |names| names[:key] == key }

    config[:names].values.map(&:first).join(" — ")
  end
end
