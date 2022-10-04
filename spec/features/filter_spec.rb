# frozen_string_literal: true

RSpec.describe "word filter" do
  before do
    words.each do |word|
      create :noun, name: word
    end

    visit search_path
  end

  let(:words) do
    %w[
      Abfall
      Abend
      Bach
    ]
  end

  it "filters words", js: true do
    words.each do |word|
      expect(page).to have_content word
    end

    fill_in t("filter.wordstarts"), with: "a"

    expect(page).to have_content "Abfall"
    expect(page).to have_content "Abend"
    expect(page).not_to have_content "Bach"

    click_on t("filter.reset")

    words.each do |word|
      expect(page).to have_content word
    end
  end
end
