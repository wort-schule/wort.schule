# frozen_string_literal: true

class Fonts
  AVAILABLE_FONTS = [
    {name: "Druckschrift Buch", filename: "DRBuch"},
    {name: "Druckschrift Hand", filename: "DRHand"},
    {name: "Grundschrift", filename: "GS"},
    {name: "Lateinische Ausgangsschrift", filename: "LA"},
    {name: "Schulausgangsschrift", filename: "SAS"},
    {name: "Vereinfachte Ausgangsschrift", filename: "VA"}
  ]

  def self.keys
    AVAILABLE_FONTS.map { |font| font[:filename] }
  end

  def self.by_key(key)
    AVAILABLE_FONTS.find { |font| font[:filename] == key }
  end

  def self.collection
    AVAILABLE_FONTS.map { |font| [font[:name], font[:filename]] }
  end
end
