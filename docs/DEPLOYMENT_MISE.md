# Deployment with mise

This project has been configured to use [mise](https://mise.jdx.dev/) for Ruby version management on the production server instead of rvm.

## Why mise?

- Modern, fast polyglot runtime manager
- Better performance than rvm
- Simpler configuration
- Supports multiple languages (not just Ruby)
- Compatible with .ruby-version files

## Server Setup

### Initial Installation

1. SSH into the production server as the deployment user:
   ```bash
   ssh wortschule@wort.schule
   ```

2. Run the setup script from the project directory:
   ```bash
   cd ~/app/current
   ./bin/setup-mise-on-server
   ```

   Or install manually:
   ```bash
   curl https://mise.jdx.dev/install.sh | sh
   echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
   source ~/.bashrc
   mise install ruby@3.4.6
   mise use ruby@3.4.6 --global
   ```

3. Verify installation:
   ```bash
   mise --version
   ruby --version
   ```

## Deployment Configuration

The deployment has been updated to use mise automatically:

- `config/deploy.rb` - Now loads `lib/mina/mise` instead of `mina/rvm`
- `lib/mina/mise.rb` - Custom mina task for mise integration
- Automatically detects and uses the Ruby version from `.ruby-version`

## Deployment Commands

Deploy as usual:
```bash
mina deploy
```

The deployment will automatically:
1. Activate mise on the server
2. Use the correct Ruby version from .ruby-version
3. Install gems with bundler
4. Run migrations
5. Precompile assets
6. Restart services

## Troubleshooting

If you encounter Ruby version issues:

1. Ensure mise is installed on the server:
   ```bash
   ssh wortschule@wort.schule
   which mise  # Should show ~/.local/bin/mise or /usr/local/bin/mise
   ```

2. Check available Ruby versions:
   ```bash
   mise list ruby
   ```

3. Install missing Ruby version:
   ```bash
   mise install ruby@3.4.6
   ```

4. Set as default:
   ```bash
   mise use ruby@3.4.6 --global
   ```

## Rollback to rvm

If needed, you can rollback to rvm by:
1. Reverting changes in `config/deploy.rb`
2. Removing `lib/mina/mise.rb`
3. Ensuring rvm is still installed on the server