json.cache! ["v1", "word_index", @letter], expires_in: 15.minutes do
  json.letter @letter
  json.words @words do |word|
    json.id word[:base_record].id
    json.name word[:base_record].name
    json.slug word[:base_record].slug
    json.url url_for([word[:base_record], {only_path: false}])
  end
end
