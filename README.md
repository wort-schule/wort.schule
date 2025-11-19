# wort.schule

## Development Setup

wort.schule uses [Ruby on Rails](https://rubyonrails.org/) as a framework and [PostgreSQL](https://www.postgresql.org) as the default database.

1. Clone the repository:
    `git clone https://github.com/wintermeyer/wort.schule`
2. `cd wort.schule`
3. Install Ruby version defined in `.ruby-version`
 (e.g. use [asdf](https://asdf-vm.com/))])
4. Install vips
 (e.g. `brew install vips` on macOS with [Homebrew](https://brew.sh))
5. Run `bin/setup` (der entsprechende User benötigt Superuser Rechte für diesen Schritt)
6. Run `bin/rails db:create db:migrate`
 (do a `bin/rails db:drop` first if you want to delete an already existing database)
7. Run `bin/rails 'word_images:import[db/seeds/word_images]'` to import images associated to words
8. Run `bin/dev`
9. Open the browser and navigate to http://localhost:3000/

The initial data is loaded by a migration, so that the database schema can be adapted without adapting the schema of the initial data.

### Misc

- Do not use `db:setup`, because that loads the schema without running all migrations.
- Start the development server using `bin/dev`

## Tidewave AI Coding Assistant

This project includes [Tidewave](https://github.com/tidewave-ai/tidewave_rails), an AI-powered coding agent specifically designed for Rails development. Tidewave provides an interactive interface to help you with:

- Writing and modifying Rails code
- Database schema design and migrations
- Creating views and UI components
- Debugging and refactoring
- Full-stack development from database to frontend

### How to use Tidewave

1. Start the development server: `bin/dev`
2. Open your browser and navigate to http://localhost:3000/tidewave
3. Use the Tidewave interface to interact with the AI assistant

**Note:** Tidewave requires the Rails server to run with limited threads for proper operation. This is automatically configured when using `bin/dev`.

## Tests

```
bin/rails spec
```

## Production Setup

- Change email address of `config.mailer_sender` in `config/initializers/devise.rb`
- Check SMTP settings in `config/environments/production.rb`
- Configure ActiveStorage in `config/storage.yml`
- Configure the host of `config.action_mailer.default_url_options` in `config/environments/production.rb`
- Import word images: `bin/rails 'word_images:import[db/seeds/word_images]'` (replace argument in `[]` with directory containing the images)

## Application Management

### Show/hide blank word attributes

Configure in `config/application.rb` whether blank attributes of words should be shown or not:

```ruby
config.hide_blank_items = true
```

Restart the Rails server when changing the configuration.

### Configure Review Requirements

Control how many confirmed reviews are required before LLM enrichment changes are automatically applied to words. Set via Rails console:

```ruby
# Require 1 confirmed review (default - auto-applies immediately)
GlobalSetting.reviews_required = 1

# Require 2 confirmed reviews for higher quality control
GlobalSetting.reviews_required = 2

# Require 3 or more confirmed reviews
GlobalSetting.reviews_required = 3

# Check current setting
GlobalSetting.reviews_required # => 1
```

When `reviews_required = 1`, reviewers do not need to review the same item twice. Skipped items stay in the queue for possible re-review later, but confirmed changes are immediately applied.

### Create an Administrator

The first administrator needs to be created manually in the Rails console (`bin/rails c`):

```ruby
password = SecureRandom.hex
# Take note of the password

Admin.create(email: 'muster@example.com', password:, password_confirmation: password)
```

## Docker Setup

There is a `Dockerfile` and an example `docker-compose.yml.example` for a production setup of the application within Docker. Note that you should customize the `docker-compose.yml` before running it in production.

After installing Docker and `docker-compose`, run `docker-compose up` in this directory to start the application.

To quickly test the application locally without customizing the `docker-compose.yml`, you may run `docker-compose -f docker-compose.yml.example up` in this directory.


## Text to speech

### Requirements

- Activate Text to Speech API for the Google Cloud Account
- Generate service credentials and download JSON file
- Place the JSON file in `config/google-tts-credentials.json`

### Processing

- Processing happens in the background via `app/jobs/tts_job.rb`. This can be triggeredy manually via `TtsJob.perform_now(word)`.
- The `good_job` gem handles the job. Start via `bundle exec good_job`
- There is a `with_tts` flag on the word model, which determines whether an audio attachment for both the word itself and it's example sentences should be generated.
- The audio is generated via Google Cloud Text to Speech API and attached to the word.
- There is a dedicated log file for the job in `log/tts.log`.
- The voice is randomly selected from the list in the config file.

To process all words, do: `Word.where(with_tts: true).each { |w| TtsJob.perform_later(w) }` (or perform_now when there is no job runner).

