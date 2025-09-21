require "mina/rails"
require "mina/git"
require "mina/rvm"

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, "wortschule"
set :domain, "wort.schule"
set :user, fetch(:application_name)
set :deploy_to, "/home/wortschule/app"
set :repository, "git@github.com:wort-schule/wort.schule.git"
set :branch, "main"
set :rvm_use_path, "/etc/profile.d/rvm.sh"
set :bundle_prefix, "env $(cat .env | xargs) bundle exec "

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
set :user, "wortschule"
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
set :shared_files, fetch(:shared_files, []).push("config/database.yml", ".env", "config/google-tts-credentials.json")
set :shared_dirs, fetch(:shared_dirs, []).push("public/packs", "node_modules", "storage", "tmp/pids")

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  ruby_version = File.read(".ruby-version").strip
  raise "Couldn't determine Ruby version: Do you have a file .ruby-version in your project root?" if ruby_version.empty?

  # Load RVM and use the correct Ruby version
  command %(
    source #{fetch(:rvm_use_path)}
    rvm install #{ruby_version} --quiet-curl 2>/dev/null || true
    rvm use #{ruby_version} --default
    rvm #{ruby_version} do ruby --version
  )
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  in_path(fetch(:shared_path)) do
    command %(mkdir -p config tmp/pids)

    # Create database.yml for Postgres if it doesn't exist
    path_database_yml = "config/database.yml"
    database_yml = %(production:
  database: #{fetch(:user)}
  adapter: postgresql
  pool: 5
  timeout: 5000)
    command %(test -e #{path_database_yml} || echo "#{database_yml}" > #{path_database_yml})

    # Create env file if it doesn't exist
    path_env_file = ".env"
    env_file = %(RAILS_ENV=production\nSECRET_KEY_BASE=#{`bundle exec rake secret`.strip}\nLLM_MODEL=llama3.1:70b\nPIDFILE=tmp/pids/server.pid)
    command %(test -e #{path_env_file} || echo "#{env_file}" > #{path_env_file})

    # Remove others-permission for config directory and env file
    command %(chmod -R o-rwx config .env)
  end
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'

  # Get the commit SHA from the local repository before deploying
  commit_sha = `git rev-parse HEAD`.strip
  ruby_version = File.read(".ruby-version").strip

  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"

    # Ensure we're using the correct Ruby version for bundler
    # First install the Ruby version if it's not available, then use it
    command %(
      source #{fetch(:rvm_use_path)}
      rvm list | grep -q "#{ruby_version}" || rvm install #{ruby_version} --quiet-curl
      rvm use #{ruby_version}
      echo "Using Ruby: $(ruby --version)"
    )

    # Use custom bundle install with RVM to ensure correct Ruby version
    command %(
      source #{fetch(:rvm_use_path)}
      rvm use #{ruby_version}
      bundle config set --local deployment 'true'
      bundle config set --local path 'vendor/bundle'
      bundle config set --local without 'development test'
      bundle install
    )

    # Use custom db:migrate with RVM to ensure correct Ruby version
    command %(
      source #{fetch(:rvm_use_path)}
      rvm use #{ruby_version}
      export $(cat .env | xargs)
      RAILS_ENV=production bundle exec rails db:migrate
    )

    # Generate deployment info file with timestamp and git commit
    # Using the commit SHA from the local repo since the deployed directory may not have .git
    command %(
      echo "Writing deployment info..."
      DEPLOY_TIME=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
      COMMIT_SHA="#{commit_sha}"
      printf "timestamp: \\"%s\\"\\ncommit: \\"%s\\"\\ncommit_url: \\"https://github.com/wort-schule/wort.schule/commit/%s\\"\\n" "$DEPLOY_TIME" "$COMMIT_SHA" "$COMMIT_SHA" > config/deployment_info.yml || echo "Warning: Could not write deployment info"
      if [ -f config/deployment_info.yml ]; then
        echo "Deployment info written successfully:"
        cat config/deployment_info.yml
      else
        echo "Warning: deployment_info.yml not created, but continuing deployment"
      fi
    )

    # Use custom assets precompile with RVM to ensure correct Ruby version
    command %(
      source #{fetch(:rvm_use_path)}
      rvm use #{ruby_version}
      export $(cat .env | xargs)
      RAILS_ENV=production bundle exec rails assets:precompile
    )
    invoke :"deploy:cleanup"

    on :launch do
      command "sudo systemctl restart #{fetch(:user)}"
      command "sudo systemctl restart #{fetch(:user)}-jobs"
    end
  end

  # you can use `run :local` to run tasks on local machine before or after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
