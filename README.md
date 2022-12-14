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

### Create an Administrator

The first administrator needs to be created manually in the Rails console (`bin/rails c`):

```ruby
password = SecureRandom.hex
# Take note of the password

Admin.create(email: 'muster@example.com', password:, password_confirmation: password)
```

### Create a Learning Group

The complete process of creating schools, teachers and learning groups is the following:

1. Login as an administrator
2. Create a teacher at http://localhost:3000/users/new. Use `Teacher` as the user's role.
3. Create a school at http://wort.schule/schools/new
4. While viewing that school, click on `Add teacher` to add a teacher to that school
5. While viewing that school, click on `Add learning group`. Then choose the teacher created earlier.
6. While viewing that school, click on the name of the just created learning group. You can then add students.

Some of these features are also available to teachers.

## Docker Setup

There is a `Dockerfile` and an example `docker-compose.yml.example` for a production setup of the application within Docker. Note that you should customize the `docker-compose.yml` before running it in production.

After installing Docker and `docker-compose`, run `docker-compose up` in this directory to start the application.

To quickly test the application locally without customizing the `docker-compose.yml`, you may run `docker-compose -f docker-compose.yml.example up` in this directory.


## Text to speech

### Requirements

- Activate Text to Speech API for the Google Cloud Account
- Generate service credentials and download JSON file
- Change path to credentials file in `config/tts.yml`

### Processing

- Processing happens in the background via `app/jobs/tts_job.rb`.
- The `good_job` gem handles the job.
- It's automatically started via cron config in `config/application.rb`.
- It finds all words, without audio attachment and where `with_tts` is true.
- The audio is generated via Google Cloud Text to Speech API and attached to the word.
- There is a dedicated log file for the job in `log/tts.log`.
- The voice is randomly selected from the list in the config file.