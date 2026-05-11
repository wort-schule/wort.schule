# frozen_string_literal: true

RSpec.describe WiktionarySyllableService do
  describe "#lookup" do
    it "returns syllables from Wiktionary" do
      stub_request(:get, "https://de.wiktionary.org/w/api.php")
        .with(query: hash_including(titles: "Zelle"))
        .to_return(
          status: 200,
          body: {
            query: {
              pages: {
                "123" => {
                  pageid: 123,
                  title: "Zelle",
                  revisions: [{
                    slots: {
                      main: {
                        "*" => "== Zelle ==\n{{Worttrennung}}\n:Zel·le, {{Pl.}} Zel·len\n"
                      }
                    }
                  }]
                }
              }
            }
          }.to_json,
          headers: {"Content-Type" => "application/json"}
        )

      result = described_class.lookup("Zelle")

      expect(result[:syllables]).to eq("Zel-le")
      expect(result[:source]).to eq("de.wiktionary.org")
    end

    it "returns nil syllables for missing words" do
      stub_request(:get, "https://de.wiktionary.org/w/api.php")
        .with(query: hash_including(titles: "Xyzabc"))
        .to_return(
          status: 200,
          body: {
            query: {
              pages: {
                "-1" => {
                  ns: 0,
                  title: "Xyzabc",
                  missing: ""
                }
              }
            }
          }.to_json,
          headers: {"Content-Type" => "application/json"}
        )

      result = described_class.lookup("Xyzabc")

      expect(result[:error]).to eq("not_found")
      expect(result[:syllables]).to be_nil
    end
  end
end
