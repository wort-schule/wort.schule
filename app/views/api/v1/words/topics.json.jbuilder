json.topics do
  json.array! @topics do |topic|
    json.id topic.id
    json.name topic.name
    json.words_count topic.words_count
  end
end
