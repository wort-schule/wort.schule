# Keyword Effectiveness Analytics

This document describes the `keyword_effectiveness` table in the `wortschule_production` database and how to use it for analyzing and improving keyword quality.

## How Data is Collected

### System Overview

MiMiMi is a multiplayer word-guessing game built with Phoenix LiveView. It uses word and keyword data from WortSchule (a Rails application). The analytics data is stored in the `wortschule_production` database so Rails developers can analyze it directly.

### Game Flow

1. **Game Setup**: Host creates a game with settings:
   - `rounds_count`: Number of rounds (default: 3)
   - `clues_interval`: Seconds between keyword reveals (default: 10)
   - `grid_size`: Number of word choices per round (default: 9)
   - `word_types`: Filter for Noun, Verb, Adjective, etc.

2. **Round Generation**: For each round, the system selects:
   - One target word (`word_id`) from WortSchule
   - Multiple keywords for that word (`keyword_ids`)
   - Distractor words to fill the grid (`possible_words_ids`)

3. **Gameplay**: During each round:
   - Players see a grid of images (target + distractors)
   - Keywords are revealed progressively at `clues_interval` intervals
   - First keyword appears immediately when round starts
   - Players can guess at any time by clicking an image

4. **Data Capture**: When a player makes a guess:
   - The Phoenix app records which keywords were visible
   - Exact timestamps are captured for each keyword reveal
   - The guess time and correctness are recorded
   - Data is written asynchronously to `keyword_effectiveness`

### What Gets Recorded

For each player's guess, we create **one row per keyword that was visible**:

```
Player sees: Keyword 1 (at 0s) → Keyword 2 (at 10s) → Keyword 3 (at 20s)
Player guesses at 25s

Creates 3 rows:
├─ keyword_id=1, position=1, revealed_at=T+0s,  picked_at=T+25s
├─ keyword_id=2, position=2, revealed_at=T+10s, picked_at=T+25s
└─ keyword_id=3, position=3, revealed_at=T+20s, picked_at=T+25s
```

This granular approach lets you analyze:
- Which keyword "triggered" the guess (likely the last one revealed before guessing)
- How long players thought after seeing each keyword
- Whether earlier or later keywords are more effective

### Data Source Details

| Data | Source | Notes |
|------|--------|-------|
| `word_id` | WortSchule `words.id` | The target word player should guess |
| `keyword_id` | WortSchule `words.id` | Keywords are also words (many-to-many self-reference) |
| `pick_id` | MiMiMi `picks.id` | UUID, links to player's guess record |
| `round_id` | MiMiMi `rounds.id` | UUID, links to game round |
| Timestamps | Phoenix LiveView | Captured in real-time during gameplay |

### Timing Accuracy

- **`revealed_at`**: Captured when the keyword is broadcast to players (server time)
- **`picked_at`**: Captured when the player's click event is processed (server time)
- Both use `DateTime.utc_now()` with microsecond precision
- Network latency is minimal (typically <100ms) since this is a real-time LiveView app

### Edge Cases

- **Late joiners**: If a player joins mid-round, timestamps for already-revealed keywords are estimated based on `clues_interval`
- **No keywords shown**: If a player somehow guesses before any keyword is revealed, no analytics are recorded
- **Round timeout**: If a player doesn't guess before timeout, no data is recorded for that player/round

## Data Structure

### Table: `keyword_effectiveness`

Each row represents a single keyword that was visible when a player made a guess. If a player saw 3 keywords before guessing, 3 rows are created.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `word_id` | integer | WortSchule word ID (target word) |
| `keyword_id` | integer | WortSchule keyword ID that was shown |
| `pick_id` | UUID | Reference to the player's pick in MiMiMi |
| `round_id` | UUID | Reference to the game round in MiMiMi |
| `keyword_position` | integer | Order keyword was revealed (1st, 2nd, 3rd...) |
| `revealed_at` | timestamp | Exact time keyword was shown to player |
| `picked_at` | timestamp | Exact time player made their guess |
| `led_to_correct` | boolean | Whether the guess was correct |
| `inserted_at` | timestamp | Record creation time |

### Indexes

- `(word_id, keyword_id)` - Primary analysis index
- `(keyword_id)` - Keyword-specific queries
- `(pick_id)` - Link back to picks
- `(round_id)` - Round-specific analysis

## Rails Model

```ruby
# app/models/keyword_effectiveness.rb
class KeywordEffectiveness < ApplicationRecord
  self.table_name = 'keyword_effectiveness'

  belongs_to :word, class_name: 'WortSchule::Word', foreign_key: :word_id, optional: true

  scope :correct, -> { where(led_to_correct: true) }
  scope :incorrect, -> { where(led_to_correct: false) }
  scope :for_word, ->(word_id) { where(word_id: word_id) }
  scope :for_keyword, ->(keyword_id) { where(keyword_id: keyword_id) }

  def time_to_guess_ms
    ((picked_at - revealed_at) * 1000).to_i
  end
end
```

## Analysis Queries

### 1. Find Best Keywords for a Word

Keywords that lead to fast, correct guesses:

```ruby
# Best keywords ranked by success rate and speed
KeywordEffectiveness
  .for_word(word_id)
  .where(led_to_correct: true)
  .group(:keyword_id)
  .having('COUNT(*) >= ?', 5)  # Minimum sample size
  .select(
    :keyword_id,
    'COUNT(*) as times_correct',
    'AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time_ms'
  )
  .order('avg_time_ms ASC')
  .limit(10)
```

### 2. Find Worst Keywords for a Word

Keywords that are shown but don't help players guess correctly:

```ruby
KeywordEffectiveness
  .for_word(word_id)
  .group(:keyword_id)
  .having('COUNT(*) >= ?', 5)
  .select(
    :keyword_id,
    'COUNT(*) as total_shown',
    'SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as times_correct',
    'SUM(CASE WHEN led_to_correct THEN 1.0 ELSE 0.0 END) / COUNT(*) as success_rate'
  )
  .order('success_rate ASC')
  .limit(10)
```

### 3. Find Problematic Words

Words where players fail even after seeing all keywords:

```ruby
# Raw SQL for complex query
sql = <<-SQL
  WITH max_positions AS (
    SELECT round_id, MAX(keyword_position) as max_pos
    FROM keyword_effectiveness
    GROUP BY round_id
  ),
  final_keyword_picks AS (
    SELECT ke.word_id, ke.led_to_correct
    FROM keyword_effectiveness ke
    JOIN max_positions mp ON ke.round_id = mp.round_id
      AND ke.keyword_position = mp.max_pos
  )
  SELECT
    word_id,
    COUNT(*) as total_attempts,
    SUM(CASE WHEN NOT led_to_correct THEN 1 ELSE 0 END) as failures,
    SUM(CASE WHEN NOT led_to_correct THEN 1 ELSE 0 END)::float / COUNT(*) as failure_rate
  FROM final_keyword_picks
  GROUP BY word_id
  HAVING COUNT(*) >= 10
    AND SUM(CASE WHEN NOT led_to_correct THEN 1 ELSE 0 END)::float / COUNT(*) >= 0.5
  ORDER BY failure_rate DESC
SQL

ActiveRecord::Base.connection.execute(sql)
```

### 4. Keyword Effectiveness by Position

Check if later keywords are more helpful:

```ruby
KeywordEffectiveness
  .for_word(word_id)
  .group(:keyword_position)
  .select(
    :keyword_position,
    'COUNT(*) as total',
    'SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct',
    'AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time_ms'
  )
  .order(:keyword_position)
```

### 5. Misleading Keywords

Keywords that are shown but players still guess wrong quickly (indicates confusion):

```ruby
KeywordEffectiveness
  .for_word(word_id)
  .where(led_to_correct: false)
  .group(:keyword_id)
  .having('COUNT(*) >= ?', 5)
  .select(
    :keyword_id,
    'COUNT(*) as times_misled',
    'AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time_to_wrong_guess_ms'
  )
  .order('avg_time_to_wrong_guess_ms ASC')  # Fast wrong guesses = confusing keyword
```

## Key Metrics

### Success Rate
```ruby
success_rate = correct_count.to_f / total_count
```
- **> 0.8**: Excellent keyword
- **0.5 - 0.8**: Acceptable keyword
- **< 0.5**: Poor keyword, consider replacing

### Time to Correct Guess
```ruby
avg_time_ms = (picked_at - revealed_at) * 1000
```
- **< 5000ms**: Very effective (instant recognition)
- **5000-15000ms**: Good (thinking time)
- **> 15000ms**: Weak keyword (needed more clues)

### Failure Rate with All Keywords
Words with >50% failure rate after all keywords need attention.

## Workflow for Improving Keywords

### Step 1: Identify Problematic Words
Run the "Find Problematic Words" query to get words with high failure rates.

### Step 2: Analyze Each Word's Keywords
For each problematic word:
```ruby
word_id = 123

# Get all keyword stats
stats = KeywordEffectiveness
  .for_word(word_id)
  .group(:keyword_id)
  .select(
    :keyword_id,
    'COUNT(*) as shown',
    'SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct',
    'AVG(EXTRACT(EPOCH FROM (picked_at - revealed_at)) * 1000) as avg_time'
  )
  .order('correct DESC')

# Find the keyword names
keyword_ids = stats.map(&:keyword_id)
keywords = WortSchule::Word.where(id: keyword_ids).index_by(&:id)

stats.each do |s|
  kw = keywords[s.keyword_id]
  puts "#{kw.name}: #{s.correct}/#{s.shown} correct (#{(s.correct.to_f/s.shown*100).round}%), avg #{s.avg_time.round}ms"
end
```

### Step 3: Identify Issues
- **Low success rate keywords**: Not descriptive enough
- **Misleading keywords**: Similar to distractor words
- **Slow keywords**: Too vague or abstract

### Step 4: Replace/Improve Keywords
In WortSchule admin:
1. Remove ineffective keywords
2. Add more distinctive keywords
3. Ensure keywords distinguish target from distractors

### Step 5: Monitor Changes
After updating keywords, track new data:
```ruby
# Compare before/after a date
before_stats = KeywordEffectiveness
  .for_word(word_id)
  .where('inserted_at < ?', change_date)
  .calculate_stats

after_stats = KeywordEffectiveness
  .for_word(word_id)
  .where('inserted_at >= ?', change_date)
  .calculate_stats
```

## Automated Reports

### Daily Report: Worst Performing Keywords

```ruby
# Find keywords with >10 samples and <30% success rate in last 24 hours
KeywordEffectiveness
  .where('inserted_at >= ?', 24.hours.ago)
  .group(:word_id, :keyword_id)
  .having('COUNT(*) >= 10')
  .having('SUM(CASE WHEN led_to_correct THEN 1.0 ELSE 0.0 END) / COUNT(*) < 0.3')
  .select(
    :word_id,
    :keyword_id,
    'COUNT(*) as total',
    'SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END) as correct'
  )
```

### Weekly Report: Words Needing Attention

```ruby
# Words with overall failure rate > 50% in last week
sql = <<-SQL
  SELECT word_id,
         COUNT(DISTINCT pick_id) as unique_picks,
         SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END)::float /
           COUNT(DISTINCT pick_id) as success_rate
  FROM keyword_effectiveness
  WHERE inserted_at >= NOW() - INTERVAL '7 days'
  GROUP BY word_id
  HAVING COUNT(DISTINCT pick_id) >= 20
    AND SUM(CASE WHEN led_to_correct THEN 1 ELSE 0 END)::float /
        COUNT(DISTINCT pick_id) < 0.5
  ORDER BY success_rate ASC
SQL
```

## Notes

- **Data volume**: One row per keyword per pick. With 5 keywords avg per round and 4 players, expect ~20 rows per round.
- **Pick timing**: `picked_at` is when player clicked, `revealed_at` is when keyword appeared. Difference = thinking time.
- **Cross-database**: This table is in `wortschule_production`, pick/round UUIDs reference `mimimi_production`.
- **Minimum samples**: Use `HAVING COUNT(*) >= N` to avoid noise from small samples (recommend N=5-10).
