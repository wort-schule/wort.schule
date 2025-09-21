# frozen_string_literal: true

# Mina task for mise (polyglot runtime manager)
# https://mise.jdx.dev/

namespace :mise do
  desc "Loads mise"
  task :load do
    comment %(Loading mise)
  end
end

# Helper method to wrap commands with mise
def mise_prefix
  "eval \"$(~/.local/bin/mise activate bash)\" && "
end

# Override the remote_environment task to use mise
task :remote_environment do
  ruby_version = File.read(".ruby-version").strip
  raise "Couldn't determine Ruby version: Do you have a file .ruby-version in your project root?" if ruby_version.empty?

  comment %(Loading environment with mise and Ruby #{ruby_version})

  # Initialize mise and ensure correct Ruby version
  command %(
    # Find mise installation
    MISE_PATH=""
    if [ -f ~/.local/bin/mise ]; then
      MISE_PATH=~/.local/bin/mise
    elif [ -f /usr/local/bin/mise ]; then
      MISE_PATH=/usr/local/bin/mise
    elif command -v mise &> /dev/null; then
      MISE_PATH=$(command -v mise)
    fi

    if [ -n "$MISE_PATH" ]; then
      # Activate mise
      eval "$($MISE_PATH activate bash)"

      # Trust all config files non-interactively
      export MISE_YES=1

      # Trust the config files in the current directory
      mise trust --all || true

      # Ensure the Ruby version is installed and set
      if ! mise list ruby | grep -q "#{ruby_version}"; then
        echo "Installing Ruby #{ruby_version} with mise..."
        mise install ruby@#{ruby_version}
      fi

      # Use the specified Ruby version with --yes flag to avoid prompts
      mise use ruby@#{ruby_version} --yes || mise use ruby@#{ruby_version}

      # Verify Ruby is accessible
      echo "Using Ruby: $(ruby --version)"
    else
      echo "Error: mise not found. Please install mise on the server."
      echo "Installation: curl https://mise.jdx.dev/install.sh | sh"
      echo "Then add to ~/.bashrc: eval \\"\\$(~/.local/bin/mise activate bash)\\""
      exit 1
    fi
  )
end
