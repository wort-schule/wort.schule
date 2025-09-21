# Load deployment information if it exists
# This file is generated during deployment and contains timestamp and commit info
module Rails
  class Application
    def deployment_info
      return @deployment_info if defined?(@deployment_info)

      deployment_file = Rails.root.join("config", "deployment_info.yml")

      @deployment_info = if deployment_file.exist?
        YAML.load_file(deployment_file).deep_symbolize_keys
      end
    rescue => e
      Rails.logger.error "Failed to load deployment info: #{e.message}"
      @deployment_info = nil
    end
  end
end
