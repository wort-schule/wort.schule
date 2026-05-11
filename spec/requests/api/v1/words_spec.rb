# frozen_string_literal: true

RSpec.describe "API V1 Words", type: :request do
  describe "GET /api/v1/words" do
    let!(:noun) { create :noun, name: "Haus" }
    let!(:verb) { create :verb, name: "laufen" }

    it "returns paginated word list" do
      get "/api/v1/words"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["meta"]["total"]).to be >= 2
      expect(body["words"]).to be_an(Array)
      expect(body["words"].first).to include("id", "name", "slug", "type", "word_type")
    end

    it "filters by type" do
      get "/api/v1/words", params: {type: "Verb"}

      body = JSON.parse(response.body)
      types = body["words"].map { |w| w["type"] }.uniq
      expect(types).to eq(["Verb"])
    end

    it "searches by name" do
      get "/api/v1/words", params: {q: "Haus"}

      body = JSON.parse(response.body)
      expect(body["words"].any? { |w| w["name"] == "Haus" }).to be true
    end
  end

  describe "GET /api/v1/words/:id" do
    let!(:noun) { create :noun, name: "Haus" }

    it "returns word details" do
      get "/api/v1/words/#{noun.slug}"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Haus")
      expect(body["type"]).to eq("Noun")
      expect(body).to include("syllables", "example_sentences", "topics", "noun")
    end

    it "returns 404 for unknown word" do
      get "/api/v1/words/nonexistent"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/words/topics" do
    let!(:topic) { create :topic }

    it "returns topics list" do
      get "/api/v1/words/topics"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["topics"]).to be_an(Array)
      expect(body["topics"].first).to include("id", "name")
    end
  end

  describe "GET /api/v1/words/hierarchies" do
    let!(:hierarchy) { create :hierarchy }

    it "returns hierarchies list" do
      get "/api/v1/words/hierarchies"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["hierarchies"]).to be_an(Array)
    end
  end

  describe "CORS" do
    it "allows cross-origin requests" do
      get "/api/v1/words", headers: {"Origin" => "https://supportoer.example.com"}

      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
    end
  end
end
