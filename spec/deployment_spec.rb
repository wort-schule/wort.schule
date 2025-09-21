require "rails_helper"
require "tempfile"

RSpec.describe "Deployment Configuration" do
  describe "deploy.rb" do
    it "has valid Ruby syntax" do
      deploy_file = Rails.root.join("config", "deploy.rb")
      expect(deploy_file).to exist

      # Check that the Ruby syntax is valid
      result = system("ruby -c #{deploy_file}", out: File::NULL, err: File::NULL)
      expect(result).to be true
    end

    it "generates valid deployment info YAML" do
      # Test the actual command that will be run during deployment
      Tempfile.create("deployment_info.yml") do |f|
        cmd = %(
          DEPLOY_TIME=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
          COMMIT_SHA=$(git rev-parse HEAD)
          printf "timestamp: \\"%s\\"\\ncommit: \\"%s\\"\\ncommit_url: \\"https://github.com/wort-schule/wort.schule/commit/%s\\"\\n" "$DEPLOY_TIME" "$COMMIT_SHA" "$COMMIT_SHA" > #{f.path}
        )

        # Run the command
        expect(system(cmd)).to be true

        # Check that valid YAML was generated
        content = File.read(f.path)
        yaml = YAML.safe_load(content)

        expect(yaml).to have_key("timestamp")
        expect(yaml).to have_key("commit")
        expect(yaml).to have_key("commit_url")
        expect(yaml["commit_url"]).to include("github.com/wort-schule/wort.schule/commit/")
      end
    end
  end
end