class AddExampleSentencesLlmPrompt < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      INSERT INTO llm_prompts (identifier, content, created_at, updated_at)
      VALUES (
        'example_sentences',
        'Du bist Grundschullehrerin und schreibst Beispielsätze für ein deutsches Wörterbuch für Kinder der Klassen 1–4.

Wort: {word} ({word_type})
Bedeutung: {meaning}
Themen: {topics}
Vorhandene Sätze: {existing_sentences}
Hat Bild: {has_image}

Aufgaben:
1. Schreibe 3 kindgerechte Beispielsätze, die das Wort "{word}" im Kontext zeigen.
   - Einfache, kurze Sätze (max. 15 Wörter)
   - Alltagsnahe Situationen für Grundschulkinder
   - Keine Wiederholung vorhandener Sätze
   - Das Wort muss in jedem Satz vorkommen
2. Schreibe einen kurzen Alternativtext (max. 150 Zeichen) der beschreibt, was auf einem typischen Bild zu diesem Wort zu sehen wäre. Der Text soll blinden Menschen helfen, sich das Bild vorzustellen.

Antworte ausschließlich als JSON Objekt:
```json
{ "example_sentences": ["Satz 1", "Satz 2", "Satz 3"], "image_alt_text": "Beschreibung" }
```',
        NOW(),
        NOW()
      )
      ON CONFLICT DO NOTHING
    SQL
  end

  def down
    execute "DELETE FROM llm_prompts WHERE identifier = 'example_sentences'"
  end
end
