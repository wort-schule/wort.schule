# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

wort.schule is a Ruby on Rails 7.2 application for German language learning, using PostgreSQL as the database. It features word management, learning groups, text-to-speech functionality via Google Cloud, and AI-powered enrichments.

## Core Commands

### Development
```bash
# Initial setup
bin/setup
bin/rails db:create db:migrate
bin/rails 'word_images:import[db/seeds/word_images]'

# Start development server (runs web server with limited threads for Tidewave, Tailwind CSS, and background jobs)
bin/dev

# Access Tidewave AI coding agent
# Navigate to http://localhost:3000/tidewave after starting the server

# Run tests
bin/rails spec

# Run a single test file
bin/rails spec spec/path/to/spec_file.rb

# Linting (uses StandardRB/RuboCop)
bin/rubocop
bundle exec standardrb

# Rails console
bin/rails c
```

### Background Jobs
```bash
# Manually run good_job worker (automatically started with bin/dev)
bundle exec good_job

# Process TTS for words
# In Rails console: TtsJob.perform_now(word)
```

## Architecture

### Key Models
- **Word** (base class with STI): Noun, Verb, Adjective, FunctionWord
- **User**: Authentication via Devise
- **LearningGroup** & **LearningGroupMembership**: Group learning functionality
- **List** & **ListItem**: User-created word lists
- **Theme**: Custom learning themes
- **LlmService** & **LlmEnrichment**: AI-powered content generation

### View Components
Located in `app/components/`, using ViewComponent pattern for reusable UI elements (e.g., BoxComponent, WordHeaderComponent, ThemeComponent).

### Background Processing
Uses `good_job` gem for job processing, including:
- **TtsJob**: Google Cloud Text-to-Speech integration
- **EnrichWordJob**: AI enrichment of word data
- **ImportWordJob**: Bulk word imports

### Authentication & Authorization
- **Devise** for user authentication
- **CanCanCan** for authorization with Ability model
- Separate Admin model for administrative access

### Testing
RSpec with:
- Feature specs using Capybara and Cuprite (headless Chrome)
- FactoryBot for test data
- SimpleCov for coverage reporting

### Assets
- **Tailwind CSS** for styling (watched via bin/dev)
- **Importmap** for JavaScript management
- **Stimulus** for JavaScript controllers
- **Turbo** for SPA-like functionality

### Important Configuration
- TTS credentials: `config/google-tts-credentials.json`
- Database views managed by Scenic gem
- Hide blank attributes: `config.hide_blank_items` in `config/application.rb`

### Development Tools
- **Tidewave**: AI-powered coding agent available at `/tidewave` route (development only)
  - Requires Rails server to run with `RAILS_MAX_THREADS=1 WEB_CONCURRENCY=1` (automatically configured in bin/dev)
  - Deep integration for full-stack Rails development from database to UI

## Testing Philosophy
Always start new features or bugfixes by writing or updating tests first.
- Keep the use of JavaScript to a minimum.
- When creating a new feature or fixing a bug: Always start by creating a test for that.
- Always run the tests and fix any issue after you implimented a new feature or fixed a bug.

## Code Quality
**IMPORTANT**: After making any code changes, ALWAYS run the linter to ensure code quality:
```bash
bundle exec standardrb --no-fix
```
If there are any lint errors, fix them before considering the task complete.