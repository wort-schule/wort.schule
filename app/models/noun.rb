class Noun < Word
  belongs_to :genus, optional: true
  validates_presence_of :name

  belongs_to :genus_masculine, class_name: "Noun", optional: true
  belongs_to :genus_feminine, class_name: "Noun", optional: true
  belongs_to :genus_neuter, class_name: "Noun", optional: true

  scope :by_genus, ->(genus) {
    where(genus: Genus.find_by(name: genus))
  }

  def article_definite(case_number: 1, singular: true)
    return "" if genus_id.blank? && singular

    case case_number
    when 1
      if singular
        %w[der die das der/die der/das die/das der/die/das][genus_id]
      else
        "die"
      end
    when 2
      if singular
        %w[des der des des/der des der/des des/der][genus_id]
      else
        "der"
      end
    when 3
      if singular
        %w[dem der dem dem/der dem der/dem dem/der][genus_id]
      else
        "den"
      end
    when 4
      if singular
        %w[den die das den/die den/das die/das den/die/das][genus_id]
      else
        "die"
      end
    end
  end

  def article_indefinite
    %w[ein eine ein ein/eine ein eine/ein ein/eine][genus_id] unless genus_id.nil?
  end
end
