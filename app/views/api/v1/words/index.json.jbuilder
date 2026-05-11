json.meta do
  json.total @total
  json.page @words.current_page
  json.per_page @words.limit_value
  json.total_pages @words.total_pages
end

json.words do
  json.array! @words do |word|
    json.partial! "api/v1/words/word_summary", word: word
  end
end
