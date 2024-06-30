# frozen_string_literal: true

class Numerus
  NAMES = [
    {
      key: "default",
      singular: "Singular",
      plural: "Plural",
      singularetantum: "Singularwort",
      pluraletantum: "Pluralwort"
    },
    {
      key: "german",
      singular: "Einzahl",
      plural: "Mehrzahl",
      singularetantum: "Einzahlwort",
      pluraletantum: "Mehrzahlwort"
    }
  ].freeze

  def self.singular(key)
    NAMES.find { |names| names[:key] == (key || "default") }[:singular]
  end

  def self.plural(key)
    NAMES.find { |names| names[:key] == (key || "default") }[:plural]
  end

  def self.singularetantum(key)
    NAMES.find { |names| names[:key] == (key || "default") }[:singularetantum]
  end

  def self.pluraletantum(key)
    NAMES.find { |names| names[:key] == (key || "default") }[:pluraletantum]
  end

  def self.keys
    as_collection.map(&:second)
  end

  def self.as_collection
    NAMES
      .map do |config|
        key = config[:key]
        label = label_all(config[:key])

        [label, key]
      end
  end

  def self.label_all(key)
    config = NAMES.find { |names| names[:key] == key }

    "#{config[:singular]}/#{config[:plural]} — #{config[:singularetantum]}/#{config[:pluraletantum]}"
  end
end
