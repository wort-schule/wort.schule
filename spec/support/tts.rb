# frozen_string_literal: true

RSpec.shared_examples "TTS" do |klass|
  let!(:word) { create(klass.model_name.singular) }

  context "when audio is attached" do
    it "displays the audio player" do
      word.audios.attach(fixture_file_upload("audio.mp3", "audio/mpeg"))

      visit send("#{klass.model_name.singular}_path", word)
      expect(page).to have_selector("audio")
    end
  end

  context "when audio is not attached" do
    it "does not display the audio player" do
      visit send("#{klass.model_name.singular}_path", word)
      expect(page).not_to have_selector("audio")
    end
  end
end
