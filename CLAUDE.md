# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

wort.schule is a Ruby on Rails 8.1 application (running on Ruby 4.0) for German language learning, using PostgreSQL as the database. It features word management, learning groups, text-to-speech functionality via Google Cloud, and AI-powered enrichments.

## Working with me

I'm learning Ruby on Rails. Treat me as a beginner.

- **Pause and ask before anything non-trivial.** If my request is ambiguous, or the approach I'm suggesting doesn't make sense, stop and interview me before writing code. Don't silently work around a bad idea. Call it out.
- **Teach actively.** When you make a non-obvious choice (which test layer, why a validation instead of a callback, why a scope instead of a class method), explain the reasoning in one or two sentences and name the Rails concept involved. Mention alternatives you rejected when it helps me build a mental model.
- **Polish my English.** English isn't my first language. Improve wording in:
  - Your own output: code comments, commit messages, PR descriptions, chat replies.
  - Variable, method, and class names you introduce (no drive-by renames in unrelated code).
  - The way you echo my prompts back. If my request was awkwardly worded, restate it in cleaner English before answering so I see the improved phrasing.

  Do **not** rewrite user-facing app text (UI labels, flash messages, German content) unless I explicitly ask.

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

# Run tests (Rails default Minitest)
bin/rails test            # unit, integration, controller, mailer, job, etc.
bin/rails test:system     # Cuprite-driven browser tests (slower)

# Run a single test file or test
bin/rails test test/models/word_test.rb
bin/rails test test/models/word_test.rb:42

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
Vanilla Rails Minitest with:
- System tests under `test/system/` using Capybara + Cuprite (headless Chrome)
- Unit/integration tests under `test/{models,controllers,services,jobs,...}`
- FactoryBot for test data (factories live in `test/factories/`)
- Vanilla `Minitest::Mock` and `Object#stub` for mocking — no Mocha
- Shared test helpers in `test/support/`:
  - `CrudTests` — class method `crud_tests_for(klass)` for CRUD UI flows
  - `TtsTests` — class method `tts_tests_for(klass)` for TTS audio flows
  - `CrudRequestTests` — class method `crud_request_tests_for(...)` for request-level CRUD
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

## Rails feature workflow

Every new feature or bugfix follows the same shape:

1. **Write the test first.** Pick the cheapest layer that actually covers the change:
   - **Model test** for domain logic, validations, scopes, business rules.
   - **Request test** for controller behavior and end-to-end flows that don't need a real browser.
   - **System test (Cuprite)** for behavior that depends on the browser: JavaScript, Turbo Stream updates, real form interaction.

   Start at the lowest layer that catches the bug. Add a higher-layer test only when the lower one can't see the behavior.

2. **Implement the change** to make the test pass.

3. **Run the tests** (`bin/rails test` and, if a system test was added, `bin/rails test:system`). Fix every failure before declaring done, including tests you didn't touch.

4. **Run the linter**: `bundle exec standardrb --no-fix`. Fix issues before declaring done.

## Flaky tests are broken tests

A test that passes locally but fails on CI — or passes nine times and fails the tenth — is **broken**, not "flaky". Treat it the same as a hard failure:

- **Never re-run CI to make a red turn green.** Re-running is a diagnostic step (does it reproduce?), not a remediation. If the second run is green, you've learned the failure is non-deterministic — that is the bug.
- **Don't merge on top of an intermittent red.** A green-on-second-try check is a green-with-an-asterisk; ignore the asterisk and the next person inherits the flake plus a bigger blast radius.
- **Diagnose, don't paper over.** The usual culprits in this codebase are Stimulus binding races, Turbo Frame re-renders, TomSelect widgets churning the DOM, and Capybara clicking before the element is interactable.
  - Prefer deterministic waits: `assert_selector`, `assert_text`, `assert_no_text`, `assert_current_path`. They retry internally with Capybara's wait time, so the test waits exactly as long as it needs to.
  - Reach for explicit waits over `sleep`: `find(...)` / `assert_*` block until the condition holds. Hand-rolled `sleep` is almost always the wrong fix.
  - When the DOM legitimately churns under you (Turbo re-render mid-action), wrap the racy step in `with_node_churn_retry` and assert *the outcome* immediately after, inside the same retry block — so a no-op click is caught and retried, not silently accepted.
  - When a JS widget intercepts clicks (TomSelect, reveal toggles), use the dedicated helpers in `test/support/cuprite_helpers.rb` — `force_reveal!`, `force_select_value` — instead of clicking through the widget.
- **If you genuinely can't fix the test in this PR**, do exactly one of:
  1. **Skip it** with `skip "flaky: <one-line description of the race>, see #<issue>"` *and* open a GitHub issue capturing the failure. Don't silently leave it red.
  2. **Quarantine it** by moving it out of the default `bin/rails test:system` run. Don't pretend it's passing.

  Never just retry the CI run, never delete the assertion to make the red go away, never widen the assertion until it matches whatever the page happens to render.
- **Adding a new flake costs the whole team.** Before merging a system test, run it locally **at least three times in a row**, including under load (`bin/rails test:system test/system/<file>_test.rb -n test_name` in a loop). If it doesn't survive a stress run on your laptop, it won't survive CI.

## Validation lives in the model

Anything checkable about a record (presence, format, uniqueness, length, business invariants like "a published word must have an author", cross-record constraints) is enforced as a **model validation** or model-level guard.

The rule of thumb: **the Rails console must behave the same as the web form.** If I can create an invalid record from `bin/rails c` that the web form rejects, the validation is in the wrong place.

- Don't put validation logic in controllers, form objects, or service objects.
- Don't rely on the HTML form (`required`, `pattern`) as the only check.
- Authorization (who is allowed to do this?) stays in `Ability` / CanCanCan. That is a separate concern from validity.

## Code Conventions

- Start every Ruby file with `# frozen_string_literal: true` (project-wide convention, matches the Rails framework's own AGENTS.md guidance).
- **Prefer boring Rails.** Reach for what ships with Rails first: validations, callbacks, scopes, partials, ViewComponent, Stimulus, Turbo. Don't add a new gem or invent a pattern when stock Rails covers it.
- **Avoid metaprogramming and clever Ruby.** Plain methods beat `define_method`, `method_missing`, and monkey patches. Readable beats short.
- **Keep JavaScript minimal.** Prefer Turbo plus small Stimulus controllers over hand-written JS. If a feature can be done server-rendered, do it server-rendered.