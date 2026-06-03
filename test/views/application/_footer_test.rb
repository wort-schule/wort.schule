# frozen_string_literal: true

require "test_helper"

class FooterPartialTest < ActionView::TestCase
  setup do
    # The footer partial calls `render 'deployment_info'`, which resolves
    # relative to the rendering controller's _prefixes. Pin the lookup
    # context to "application/" so the inner partial is found.
    lookup_context.prefixes = ["application"]
  end

  test "displays deployment timestamp in German format in production" do
    deployment_info = {
      timestamp: "2024-12-20 10:30:45 UTC",
      commit: "abc123def",
      commit_url: "https://github.com/wort-schule/wort.schule/commit/abc123def"
    }

    Rails.env.stub(:production?, true) do
      Rails.application.stub(:deployment_info, deployment_info) do
        render partial: "application/footer"

        # 2024-12-20 10:30:45 UTC becomes 20.12.2024 um 11:30 Uhr (CET)
        assert_includes rendered, "Bereitgestellt: 20.12.2024 um 11:30 Uhr"
      end
    end
  end

  test "displays commit SHA with link to GitHub in production" do
    deployment_info = {
      timestamp: "2024-12-20 10:30:45 UTC",
      commit: "abc123def",
      commit_url: "https://github.com/wort-schule/wort.schule/commit/abc123def"
    }

    Rails.env.stub(:production?, true) do
      Rails.application.stub(:deployment_info, deployment_info) do
        render partial: "application/footer"

        assert_includes rendered, "Commit:"
        assert_select "a[href=?]", "https://github.com/wort-schule/wort.schule/commit/abc123def", text: "abc123d"
      end
    end
  end

  test "technical bug report link points to the GitHub bug report form" do
    render partial: "application/footer"

    assert_select "a[href=?]",
      "https://github.com/wort-schule/wort.schule/issues/new?template=bug_report.yml",
      text: "Technischen Fehler melden"
  end

  test "does not display deployment information outside production" do
    Rails.env.stub(:production?, false) do
      render partial: "application/footer"
      refute_includes rendered, "Bereitgestellt:"
    end
  end

  test "does not display deployment information when deployment info is missing" do
    Rails.env.stub(:production?, true) do
      Rails.application.stub(:deployment_info, nil) do
        render partial: "application/footer"
        refute_includes rendered, "Bereitgestellt:"
      end
    end
  end
end
