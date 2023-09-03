# Allows to use `fields_for @filterrific`
class Filterrific::ParamSet
  def model_name
    ActiveModel::Name.new(Filterrific)
  end
end
