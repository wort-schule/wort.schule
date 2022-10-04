class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.as_collection
    all.order(:name).map do |element|
      [element.name, element.id]
    end
  end
end
