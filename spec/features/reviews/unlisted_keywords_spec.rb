# frozen_string_literal: true

require "rails_helper"

RSpec.describe "reviews for a new keyword" do
  include ActiveJob::TestHelper

  let(:me) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let(:other_admin) { create :admin, review_attributes: Llm::Attributes.keys_with_types }
  let!(:existing_keyword) { create(:noun, name: "Tier", with_tts: false) }
  let!(:word) { create(:noun, name: "Katze", with_tts: false) }
  let!(:edit) { create(:word_attribute_edit, word:, attribute_name: "keywords", value: %w[Tier klein].as_json) }

  after do
    clear_enqueued_jobs
  end

  let!(:get_llm_response) do
    stub_request(:post, "https://ai.test/api/chat")
      .to_return_json(
        status: 200,
        body: {
          model: "llama3.1",
          created_at: "2024-11-20T21:48:24.480952052Z",
          message: {
            role: "assistant",
            content: '{ "base_form": "klein", "topic": "" }'
          },
          done_reason: "stop",
          done: true,
          total_duration: 347987332616,
          load_duration: 19833664,
          prompt_eval_count: 726,
          prompt_eval_duration: 350627000,
          eval_count: 938,
          eval_duration: 347572054000
        }
      )
  end

  it "adds the new keyword when the change is fully confirmed", :js do
    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as me
    visit reviews_path
    expect(page).to have_content edit.word.name
    within '[data-toggle-buttons-target="list"]' do
      click_on "Tier"
      click_on "klein"
    end
    click_on I18n.t("reviews.show.actions.confirm")

    expect(edit.reload.current_value).not_to eq edit.proposed_value

    login_as other_admin
    visit reviews_path
    expect(page).to have_content edit.word.name
    within '[data-toggle-buttons-target="list"]' do
      click_on "Tier"
      click_on "klein"
    end
    expect do
      click_on I18n.t("reviews.show.actions.confirm")
    end.to change(UnlistedKeyword, :count).by(1)
      .and change(WordImport, :count).by(1)
      .and enqueue_job(ImportWordJob)

    # Only the existing keyword has been updated
    expect(edit.reload.current_value).to eq "Tier"
    expect(word.reload.keywords.pluck(:name)).to eq ["Tier"]
    expect(UnlistedKeyword.all).to match [
      have_attributes(
        word:,
        word_import: WordImport.last,
        state: "new"
      )
    ]
    expect(WordImport.all).to match [
      have_attributes(
        name: "klein",
        topic: "klein",
        word_type: "Adjective"
      )
    ]

    expect do
      perform_enqueued_jobs
    end.to change(NewWord, :count).by(1)

    # Confirm the new word
    login_as me
    visit reviews_path
    expect(page).to have_content "klein"
    expect do
      click_on I18n.t("reviews.new_word_component.create")
    end.to change(UnlistedKeyword.unprocessed, :count).by(-1)
      .and change(Adjective, :count).by(1)

    expect(UnlistedKeyword.all).to match [
      have_attributes(
        word:,
        word_import: WordImport.last,
        state: "processed"
      )
    ]
    expect(word.reload.keywords.pluck(:name)).to match_array ["Tier", "klein"]
  end
end
