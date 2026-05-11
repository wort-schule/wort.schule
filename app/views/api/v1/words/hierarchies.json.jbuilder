json.hierarchies do
  json.array! @hierarchies do |hierarchy|
    json.id hierarchy.id
    json.name hierarchy.name
    json.words_count hierarchy.words_count
  end
end
