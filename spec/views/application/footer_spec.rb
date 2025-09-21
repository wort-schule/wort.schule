require "rails_helper"

RSpec.describe "application/_footer.html.haml", type: :view do
  context "in production environment" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(Rails.application).to receive(:deployment_info).and_return({
        timestamp: "2024-12-20 10:30:45 UTC",
        commit: "abc123def",
        commit_url: "https://github.com/wort-schule/wort.schule/commit/abc123def"
      })
    end

    it "displays deployment timestamp" do
      render
      expect(rendered).to include("Bereitgestellt: 2024-12-20 10:30:45 UTC")
    end

    it "displays commit SHA with link to GitHub" do
      render
      expect(rendered).to have_link("abc123d", href: "https://github.com/wort-schule/wort.schule/commit/abc123def")
    end
  end

  context "in non-production environment" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
    end

    it "does not display deployment information" do
      render
      expect(rendered).not_to include("Bereitgestellt:")
    end
  end

  context "when deployment info file is missing" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(Rails.application).to receive(:deployment_info).and_return(nil)
    end

    it "does not display deployment information" do
      render
      expect(rendered).not_to include("Bereitgestellt:")
    end
  end
end
