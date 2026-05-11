# frozen_string_literal: true

class WiktionarySyllableService
  WIKTIONARY_API = "https://de.wiktionary.org/w/api.php"

  def self.lookup(word)
    new.lookup(word)
  end

  def lookup(word)
    response = connection.get do |req|
      req.params = {
        action: "query",
        titles: word,
        prop: "revisions",
        rvprop: "content",
        rvslots: "main",
        format: "json"
      }
    end

    body = response.body
    body = JSON.parse(body) if body.is_a?(String)

    parse_response(body, word)
  rescue => e
    {error: e.message, syllables: nil}
  end

  private

  def connection
    @connection ||= Faraday.new(url: WIKTIONARY_API) do |f|
      f.headers["User-Agent"] = "wort.schule/1.0 (https://wort.schule; educational project) Ruby/Faraday"
      f.headers["Accept"] = "application/json"
      f.response :json, content_type: /\bjson$/
      f.adapter Faraday.default_adapter
    end
  end

  def parse_response(body, word)
    pages = body.dig("query", "pages")
    return {error: "not_found", syllables: nil} if pages.nil?

    page = pages.values.first
    return {error: "not_found", syllables: nil} if page["missing"]

    content = page.dig("revisions", 0, "slots", "main", "*") ||
      page.dig("revisions", 0, "*")
    return {error: "no_content", syllables: nil} if content.nil?

    syllables = extract_syllables(content)

    {
      syllables: syllables,
      source: "de.wiktionary.org",
      word: word
    }
  end

  def extract_syllables(content)
    match = content.match(/\{\{Worttrennung\}\}\s*\n:([^\n]+)/i)
    return nil unless match

    raw = match[1]
    singular = raw.split(/,|\{\{Pl\.?\}\}/i).first&.strip
    return nil if singular.blank?

    singular = singular.gsub(/\{\{[^}]*\}\}/, "").strip
    singular.tr("·", "-")
  end
end
