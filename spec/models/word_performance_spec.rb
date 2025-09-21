require "rails_helper"

RSpec.describe "Word Model Performance", type: :model do
  describe "consonant_vowel attribute" do
    let(:word) { create(:noun, name: "Hund") }

    it "sets consonant vowel pattern on save" do
      expect(word.consonant_vowel).to eq("KVKK")
    end
  end

  describe "#hit!" do
    let(:word) { create(:noun, hit_counter: 5) }
    let(:session) { {} }
    let(:user_agent) { "Mozilla/5.0" }

    it "uses database increment for hit counter" do
      expect(word).to receive(:increment!).with(:hit_counter).and_call_original
      word.hit!(session, user_agent)
    end

    it "increments hit counter" do
      expect { word.hit!(session, user_agent) }.to change { word.reload.hit_counter }.by(1)
    end
  end
end
