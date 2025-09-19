# frozen_string_literal: true

# Load deployment information
module DeploymentInfo
  class << self
    def timestamp
      @timestamp ||= load_timestamp
    end

    def git_revision
      @git_revision ||= load_git_revision
    end

    def deployed_at
      return nil unless timestamp
      Time.parse(timestamp).in_time_zone("Europe/Berlin")
    rescue ArgumentError
      nil
    end

    def short_revision
      return nil unless git_revision
      git_revision[0..6]
    end

    private

    def load_timestamp
      timestamp_file = Rails.root.join("DEPLOY_TIMESTAMP")
      return nil unless File.exist?(timestamp_file)
      File.read(timestamp_file).strip
    end

    def load_git_revision
      revision_file = Rails.root.join("REVISION")
      return nil unless File.exist?(revision_file)
      File.read(revision_file).strip
    end
  end
end
