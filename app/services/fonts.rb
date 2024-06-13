# frozen_string_literal: true

class Fonts
  AVAILABLE_FONTS = [
    {name: "Druckschrift Buch", filename: "DRBuch"},
    {name: "Druckschrift Hand", filename: "DRHand"},
    {name: "Grundschrift", filename: "GS"},
    {name: "Lateinische Ausgangsschrift", filename: "LA"},
    {name: "Schulausgangsschrift", filename: "SAS"},
    {name: "Vereinfachte Ausgangsschrift", filename: "VA"}
  ].freeze

  SYLLABLE_ARCS = {
    (0..300) => "01",
    (301..550) => "04",
    (551..600) => "05",
    (601..700) => "06",
    (701..750) => "07",
    (751..800) => "08",
    (801..900) => "09",
    (901..1000) => "10",
    (1001..1020) => "11",
    (1021..1100) => "12",
    (1101..1150) => "13",
    (1151..1200) => "14",
    (1201..1350) => "16",
    (1351..1450) => "17",
    (1451..1500) => "18",
    (1501..1600) => "19",
    (1601..1650) => "20",
    (1651..1700) => "21",
    (1701..1800) => "22",
    (1801..1850) => "23",
    (1851..1900) => "24",
    (1901..2000) => "25",
    (2001..2100) => "26",
    (2101..2200) => "27",
    (2201..2400) => "29",
    (2401..2500) => "31",
    (2501..2600) => "32",
    (2601..2650) => "33",
    (2651..2700) => "34",
    (2701..2800) => "35",
    (2801..2900) => "36",
    (2901..3000) => "37",
    (3001..3100) => "38",
    (3101..3200) => "39",
    (3201..3300) => "40",
    (3301..3350) => "41",
    (3351..3400) => "42",
    (3401..3500) => "43",
    (3501..3600) => "44",
    (3601..3700) => "45",
    (3701..3800) => "46",
    (3801..3900) => "47"
  }

  def self.default
    AVAILABLE_FONTS.first
  end

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
