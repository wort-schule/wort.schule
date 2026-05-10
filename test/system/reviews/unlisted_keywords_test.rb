# frozen_string_literal: true

require "application_system_test_case"

class ReviewsUnlistedKeywordsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @me = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @other_admin = create(:admin, review_attributes: Llm::Attributes.keys_with_types)
    @existing_keyword = create(:noun, name: "Tier", with_tts: false)
    @word = create(:noun, name: "Katze", with_tts: false)
    @edit = create(:word_attribute_edit, word: @word, attribute_name: "keywords", value: [@existing_keyword.id, "klein"].to_json)
    @llm_service = create(:llm_service)

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

  teardown do
    clear_enqueued_jobs
  end

  test "adds the new keyword when the change is fully confirmed" do
    refute_equal @edit.proposed_value, @edit.reload.current_value

    login_as @me
    visit reviews_path
    assert_text @edit.word.name

    within '[data-toggle-buttons-target="list"]' do
      click_on @existing_keyword.name
      click_on "klein"
    end

    assert_difference -> { Review.count }, +1 do
      assert_difference -> { UnlistedKeyword.count }, +1 do
        assert_difference -> { WordImport.count }, +1 do
          assert_enqueued_with(job: ImportWordJob) do
            click_on I18n.t("reviews.show.actions.confirm")
          end
        end
      end
    end

    assert_equal "confirmed", @edit.reload.change_group.state
    assert_equal ["Tier"], @word.reload.keywords.pluck(:name)

    assert_equal 1, UnlistedKeyword.count
    unlisted = UnlistedKeyword.first
    assert_equal @word, unlisted.word
    assert_equal WordImport.last, unlisted.word_import
    assert_equal "new", unlisted.state

    assert_equal 1, WordImport.count
    word_import = WordImport.first
    assert_equal "klein", word_import.name
    assert_equal "", word_import.topic
    assert_equal "Adjective", word_import.word_type

    assert_difference -> { NewWord.count }, +1 do
      perform_enqueued_jobs
    end

    topic = create(:topic, name: "Eigenschaften")
    login_as @me
    visit reviews_path
    assert_text "klein"

    find("#change_group_new_word_attributes_topic + .ts-wrapper .ts-control").click
    find(".ts-dropdown .option", text: topic.name).click
    find(".ts-control input").send_keys(:escape)

    assert_difference -> { UnlistedKeyword.unprocessed.count }, -1 do
      assert_difference -> { Adjective.count }, +1 do
        click_on I18n.t("reviews.new_word_component.create")
      end
    end

    assert_equal 1, UnlistedKeyword.count
    unlisted = UnlistedKeyword.first
    assert_equal @word, unlisted.word
    assert_equal WordImport.last, unlisted.word_import
    assert_equal "processed", unlisted.state
    assert_equal ["Tier", "klein"].sort, @word.reload.keywords.pluck(:name).sort
  end
end
