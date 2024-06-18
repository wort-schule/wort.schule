class Genus < ApplicationRecord
  has_one_attached :symbol

  NAMES = {
    foreign: {
      masculinum: "Maskulinum",
      femininum: "Femininum",
      neutrum: "Neutrum"
    },
    german: {
      masculinum: "männlich",
      femininum: "weiblich",
      neutrum: "sächlich"
    }
  }.freeze

  def self.keys
    NAMES.keys
  end

  def self.as_collection
    NAMES.map do |key, names|
      label = names.values.join(" — ")

      [label, key]
    end
  end

  def self.label_all(key)
    NAMES[key.to_sym].values.join(" — ")
  end

  def label(key)
    genus_keys.map do |genus_key|
      NAMES[key.to_sym][genus_key.to_sym]
    end.join("/")
  end
end
