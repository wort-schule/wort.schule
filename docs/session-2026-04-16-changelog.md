# Entwicklungssitzung 16. April 2026 — Vollstandige Dokumentation

## Ubersicht

In dieser Sitzung wurden **drei kritische Bugfixes** und **drei neue Admin-Features** implementiert, sowie eine **Datenbereinigung** der `example_sentences`-Spalte durchgefuhrt.

**Statistiken:**
- 24 neue Dateien erstellt (1.483 Zeilen)
- 9 bestehende Dateien geandert
- 4 Datenbank-Migrationen
- 536 Tests, 0 Failures
- Linter: 0 Offenses

---

## Teil 1: Bugfixes

### 1.1 Wort-Detailseiten crashen (alle Worttypen)

**Problem:** Jede einzelne Wort-Detailseite (`/prinz`, `/stempeln`, `/lockig`, etc.) warf einen 500-Fehler:
```
NoMethodError: undefined method 'each' for an instance of String
```

**Ursache:** Das Feld `example_sentences` ist als JSONB-Spalte definiert, aber die Daten waren **doppelt serialisiert**. Statt des JSON-Arrays `[]` stand der JSON-String `"[]"` in der Datenbank. Bei 7.861 Wortern. Der Aufruf `.each` in `app/views/example_sentences/_list.html.haml:4` schlug fehl, weil `.each` auf einem String nicht existiert.

**Fix (2 Teile):**

**a) Accessor im Word-Model** (`app/models/word.rb`):
```ruby
def example_sentences
  value = super
  return [] if value.blank?
  return value if value.is_a?(Array)
  parsed = value.is_a?(String) ? JSON.parse(value) : value
  parsed.is_a?(Array) ? parsed : []
rescue JSON::ParserError
  []
end
```
Dieser Accessor normalisiert den Ruckgabewert immer zu einem Array, unabhangig davon ob die Daten korrekt oder doppelt-serialisiert gespeichert sind.

**b) Datenmigration** (`db/migrate/20260416120000_fix_double_serialized_example_sentences.rb`):
```sql
UPDATE words
SET example_sentences = (example_sentences #>> '{}')::jsonb
WHERE jsonb_typeof(example_sentences) = 'string'
```
Diese Migration konvertiert alle fehlerhaft gespeicherten String-Werte in korrekte JSON-Arrays. Der PostgreSQL-Operator `#>> '{}'` extrahiert den inneren Wert eines JSON-Strings, und `::jsonb` castet ihn zuruck zu JSONB.

**Betroffene Dateien:**
- `app/models/word.rb` (11 Zeilen hinzugefugt)
- `db/migrate/20260416120000_fix_double_serialized_example_sentences.rb` (neu, 13 Zeilen)

---

### 1.2 FunctionWord-Detailseiten crashen zusatzlich

**Problem:** Funktionswort-Seiten (`/das`, `/der`) warfen einen separaten 500-Fehler:
```
NoMethodError: undefined method 'model' for nil
```

**Ursache:** `LlmService.active` gibt `nil` zuruck wenn kein aktiver LLM-Service konfiguriert ist. In `app/services/llm/invoke.rb:63` wird `LlmService.active.model` aufgerufen, was auf `nil` crasht. Zusatzlich instantiiert `app/components/theme_component.html.haml:11` `Llm::Enrich.new(word:)` bedingungslos — der Constructor ruft `default_model` auf, was ebenfalls crasht.

**Fix (2 Stellen):**

**a)** `app/services/llm/invoke.rb:63`: Safe Navigation Operator
```ruby
# Vorher:
def default_model
  LlmService.active.model
end

# Nachher:
def default_model
  LlmService.active&.model
end
```

**b)** `app/components/theme_component.html.haml:10`: Guard-Bedingung
```haml
- if helpers.can?(:manage_llm, word) && !Rails.env.test? && LlmService.active.present?
```

**Betroffene Dateien:**
- `app/services/llm/invoke.rb` (1 Zeichen geandert)
- `app/components/theme_component.html.haml` (1 Bedingung hinzugefugt)

---

### 1.3 Profil-Themes-Seite crasht

**Problem:** `/seite/profile/themes` warf einen 500-Fehler:
```
NoMethodError: undefined method 'theme_noun' for an instance of Admin
```

**Ursache:** Die Methode `theme_noun` (und `theme_verb`, `theme_adjective`, `theme_function_word`) wurde fruher direkt auf dem `User`-Model gespeichert, wurde aber in einer fruheren Migration in die separate `WordViewSetting`-Tabelle verschoben. Der Controller `profiles/themes_controller.rb:12` rief noch `current_user.public_send(theme_attribute)` auf.

**Fix** (`app/controllers/profiles/themes_controller.rb:12`):
```ruby
# Vorher:
@active_theme = current_user.public_send(theme_attribute)

# Nachher:
@active_theme = current_user.word_view_setting&.public_send(theme_attribute)
```

**Betroffene Dateien:**
- `app/controllers/profiles/themes_controller.rb` (1 Zeile geandert)

---

## Teil 2: Feature — Massenbearbeitung von Wortern

**URL:** `/seite/bulk_edits`
**Zugriff:** Nur fur Admins

### 2.1 Zweck

Ermoglicht es, mehrere Worter gleichzeitig zu bearbeiten statt jedes einzeln anklicken zu mussen. Worterphanomene, Strategien, Themen und andere Felder konnen auf hunderte Worter gleichzeitig angewendet werden.

### 2.2 Funktionen

#### Suche
- **Wildcard-Suche:** `*` = beliebig viele Zeichen, `?` = ein Zeichen
- **Anker:** `^` = Wortanfang, `$` = Wortende
  - Beispiele: `^Haus*` (beginnt mit "Haus"), `*ung$` (endet auf "-ung"), `^Haus$` (exakt "Haus")
- **Silbensuche:** Umschaltbar zwischen "Wortname" und "Silben" als Suchfeld
  - Beispiel: `*-tion` in Silbensuche findet alle Worter mit der Silbe "-tion"
- **Wortart-Filter:** Substantiv, Verb, Adjektiv, Funktionswort
- **Paginierung:** 50, 100, oder alle Ergebnisse

#### Zuweisungs-Panel (oben)
Feld-Auswahl und Werte-Zuweisung oberhalb der Ergebnistabelle:

| Feld | Typ | Operationen | Eingabe |
|------|-----|-------------|---------|
| Phanomene | HABTM | Hinzufugen / Entfernen | Multi-Select (TomSelect) |
| Strategien | HABTM | Hinzufugen / Entfernen | Multi-Select |
| Themen | HABTM | Hinzufugen / Entfernen | Multi-Select |
| Hierarchie | belongs_to | Setzen | Single-Select |
| Vorsilbe | belongs_to | Setzen | Single-Select |
| Nachsilbe | belongs_to | Setzen | Single-Select |
| Prototyp | boolean | Setzen | Checkbox |
| Fremdwort | boolean | Setzen | Checkbox |
| Kompositum | boolean | Setzen | Checkbox |

Das Panel passt sich dynamisch an: HABTM-Felder zeigen "Hinzufugen/Entfernen"-Operationen und Multi-Selects, belongs_to-Felder zeigen Single-Selects, boolean-Felder zeigen Checkboxen.

#### Ergebnistabelle
- Checkbox pro Wort + "Alle auswahlen" mit Indeterminate-State
- Zahler "X Worter ausgewahlt"
- Spalten: Name (verlinkt), Wortart (Badge), aktuelle Phanomene, aktuelle Strategien
- Zweiter "Anwenden"-Button unterhalb der Tabelle + Link zuruck zum Panel

#### Protokoll-Tab
- Tabelle aller durchgefuhrten Massenbearbeitungen
- Spalten: Datum, Benutzer, Operation (farbiges Badge), Feld, Werte, Anzahl Worter, Suchabfrage
- **Ruckgangig-Button** pro Eintrag (mit Bestatigungsdialog)
- Ruckgangig gemachte Eintrage werden ausgegraut mit Zeitstempel

#### Undo-Mechanismus
Das `BulkEdit`-Model speichert fur jede Operation die **Deltas** (nicht Snapshots):
- **HABTM "add":** Speichert pro Wort welche IDs **tatsachlich neu** hinzugefugt wurden (nicht schon vorhandene)
- **HABTM "remove":** Speichert pro Wort welche IDs **tatsachlich entfernt** wurden
- **belongs_to / boolean:** Speichert den **alten Wert** pro Wort

Beim Undo werden exakt diese Deltas ruckgangig gemacht. Zwischenzeitliche Anderungen anderer Benutzer werden nicht uberschrieben.

PaperTrail wurde bewusst nicht verwendet, da es keine HABTM-Join-Table-Anderungen trackt.

### 2.3 Neue Dateien

| Datei | Zeilen | Zweck |
|-------|--------|-------|
| `app/controllers/bulk_edits_controller.rb` | 86 | Controller: index, execute, undo + Suchlogik |
| `app/models/bulk_edit.rb` | 35 | Model: Validierungen, Scopes, Konstanten, Helper |
| `app/services/bulk_edit_service.rb` | 121 | Kernlogik: Execute + Undo fur alle Feldtypen |
| `app/helpers/bulk_edits_helper.rb` | 47 | View-Helper: Feld-Optionen, Werte-Anzeige, Badges |
| `app/views/bulk_edits/index.html.haml` | 192 | Hauptview: Tabs, Suche, Tabelle, Panel, Protokoll |
| `app/javascript/controllers/bulk_select_controller.js` | 29 | Stimulus: Select-All, Checkbox-Zahler |
| `app/javascript/controllers/bulk_edit_form_controller.js` | 29 | Stimulus: Dynamische Formularfelder |
| `app/javascript/controllers/tabs_controller.js` | 23 | Stimulus: Tab-Umschaltung |
| `db/migrate/20260416174402_create_bulk_edits.rb` | 16 | Migration: bulk_edits Tabelle |
| `spec/factories/bulk_edits.rb` | 12 | Factory fur Tests |
| `spec/services/bulk_edit_service_spec.rb` | 187 | 10 Service-Tests (Execute + Undo) |
| `spec/features/bulk_edits_spec.rb` | 100 | 5 Feature-Tests (Suche, Zuweisung, Auth) |

### 2.4 Datenbank-Schema

```sql
CREATE TABLE bulk_edits (
  id bigserial PRIMARY KEY,
  user_id bigint NOT NULL REFERENCES users(id),
  operation varchar NOT NULL,        -- "add", "remove", "set"
  field varchar NOT NULL,            -- "topics", "phenomenons", "hierarchy_id", etc.
  word_ids jsonb NOT NULL DEFAULT '[]',
  assigned_values jsonb NOT NULL DEFAULT '[]',
  previous_values jsonb NOT NULL DEFAULT '{}',
  search_query varchar,
  undone boolean DEFAULT false,
  undone_at timestamp,
  created_at timestamp NOT NULL,
  updated_at timestamp NOT NULL
);
```

---

## Teil 3: Feature — Beispielsatze-Ubersicht

**URL:** `/seite/example_sentences_overview`
**Zugriff:** Nur fur Admins

### 3.1 Zweck

Zentrale Ubersicht aller Worter mit ihren Beispielsatzen. Ermoglicht schnelles Durchsehen und Bearbeiten ohne jedes Wort einzeln offnen zu mussen.

### 3.2 Funktionen

#### Filter
- **Wortsuche:** Wildcards (`*`, `?`)
- **Bild-Filter:** Alle / Mit Bild / Ohne Bild
- **Satz-Filter:** Alle / Mit Satzen / Ohne Satze / Gepruft / Nicht gepruft
- **Paginierung:** 50 / 100 / 200 / Alle

#### Wort-Karten
Jedes Wort wird als Karte dargestellt:
- **Links:** Bild-Thumbnail (oder Platzhalter), Wortname (verlinkt zur Detailseite), Wortart, Gepruft-Badge
- **Rechts:** Editierbare Textfelder fur Beispielsatze (ein Feld pro Satz), mit:
  - Loschen-Button (X) pro Satz
  - "+ Satz hinzufugen"-Button (dynamisch via Stimulus nested-form Controller)
  - Gepruft-Checkbox (grun hervorgehoben wenn aktiv)
  - Speichern-Button

### 3.3 Neue Dateien

| Datei | Zeilen | Zweck |
|-------|--------|-------|
| `app/controllers/example_sentences_overview_controller.rb` | 60 | Controller: index + update |
| `app/views/example_sentences_overview/index.html.haml` | 89 | View: Filter + Wort-Karten |
| `spec/features/example_sentences_overview_spec.rb` | 41 | 3 Feature-Tests |

---

## Teil 4: Feature — Silbenubersicht mit Wiktionary-Abgleich

**URL:** `/seite/syllables_overview`
**Zugriff:** Nur fur Admins

### 4.1 Zweck

Ubersicht aller Worter mit ihren Sprech- und Schreibsilben. Automatischer Abgleich mit de.wiktionary.org um Fehler zu identifizieren. Gecachte Ergebnisse vermeiden wiederholte API-Aufrufe.

### 4.2 Funktionen

#### Filter
- **Wortsuche:** Wildcards (`*`, `?`)
- **Silben-Filter:**
  - Alle
  - Ohne Sprechsilben
  - Ohne Schreibsilben
  - Mit beiden Silbenarten
  - Abweichungen (Wiktionary) — zeigt nur Worter wo eigene Silben von Wiktionary abweichen
  - Noch nicht abgerufen — Worter ohne Wiktionary-Cache
  - Gepruft / Nicht gepruft
- **Paginierung:** 50 / 100 / 200 / Alle

#### Tabelle
Pro Zeile:
- **Wort:** Name (verlinkt), Wortart, Gepruft-Badge
- **Sprechsilben:** Editierbares Textfeld (Format: `Ab-hand-lung`)
- **Schreibsilben:** Editierbares Textfeld (Format: `Ab|hand|lung`)
- **Wiktionary-Spalte:**
  - Gruner Haken (check-circle) — Silben stimmen mit Wiktionary uberein
  - Rotes Kreuz (x-circle) + abweichender Wert — Silben weichen ab
  - Grauer Strich (—) — noch nicht von Wiktionary abgerufen
- **Gepruft:** Checkbox
- **Speichern:** Button pro Zeile

#### Wiktionary-Integration

**Button "Alle von Wiktionary abrufen"** (oben rechts):
- Ruft die deutsche Wiktionary-API fur alle noch nicht gecachten Worter auf
- Speichert die Ergebnisse in der Spalte `words.wiktionary_syllables`
- 0.2 Sekunden Pause zwischen Requests (Wikimedia Rate-Limit)
- User-Agent Header wird mitgeschickt (Wikimedia-Richtlinie)

**Wiktionary-API:**
- Endpoint: `https://de.wiktionary.org/w/api.php`
- Methode: `action=query&prop=revisions&rvprop=content&rvslots=main&format=json`
- Parsing: Extrahiert `{{Worttrennung}}` Template aus dem Wikitext
- Format: Konvertiert Mittelpunkt (·) zu Bindestrich (-) fur Vergleich
- Fehlerbehandlung: Gibt `{error: ..., syllables: nil}` bei Fehlern zuruck

### 4.3 Neue Dateien

| Datei | Zeilen | Zweck |
|-------|--------|-------|
| `app/controllers/syllables_overview_controller.rb` | 83 | Controller: index, update, fetch_all_wiktionary |
| `app/views/syllables_overview/index.html.haml` | 79 | View: Filter + Tabelle + Wiktionary-Spalte |
| `app/services/wiktionary_syllable_service.rb` | 72 | Wiktionary-API-Client mit Parsing |
| `app/javascript/controllers/wikidata_check_controller.js` | 48 | Stimulus: Async Wikidata-Check (Legacy) |
| `spec/features/syllables_overview_spec.rb` | 50 | 4 Feature-Tests |
| `spec/services/wiktionary_syllable_service_spec.rb` | 61 | 2 Service-Tests (mit WebMock Stubs) |

### 4.4 Datenbank-Schema-Erweiterungen

```sql
ALTER TABLE words ADD COLUMN wiktionary_syllables varchar;
ALTER TABLE words ADD COLUMN syllables_verified boolean NOT NULL DEFAULT false;
ALTER TABLE words ADD COLUMN example_sentences_verified boolean NOT NULL DEFAULT false;
```

---

## Teil 5: Geanderte bestehende Dateien

### 5.1 Routes (`config/routes.rb`)

Drei neue Resource-Blocke innerhalb des `scope "seite"` Blocks:

```ruby
resources :bulk_edits, only: :index do
  collection do
    post :execute
    post :undo
  end
end
resources :example_sentences_overview, only: %i[index update]
resources :syllables_overview, only: %i[index update] do
  post :fetch_all_wiktionary, on: :collection
end
```

### 5.2 Autorisierung (`app/models/ability.rb`)

Drei neue Permissions im Admin-Block:
```ruby
can :manage, :bulk_edit
can :manage, :example_sentences_overview
can :manage, :syllables_overview
```

### 5.3 Navigation (`app/views/pages/navigation.html.haml`)

Drei neue Nav-Cards in der "Inhaltsverwaltung"-Sektion:
- **Massenbearbeitung** (Icon: pencil-square)
- **Beispielsatze** (Icon: chat-bubble-left-right)
- **Silbenubersicht** (Icon: scissors)

Alle geschutzt mit `can?(:manage, :feature_name)`.

### 5.4 Locales

**`config/locales/navigation.de.yml`:** 6 neue Ubersetzungen (Titel + Hilfetext fur die drei Nav-Cards)

**`config/locales/views.de.yml`:** ~125 neue Ubersetzungen fur:
- `bulk_edits.index.*` (25+ Keys)
- `bulk_edits.execute.*` (3 Keys)
- `bulk_edits.undo.*` (1 Key)
- `bulk_edits.operations.*` (3 Keys)
- `example_sentences_overview.index.*` (20+ Keys)
- `example_sentences_overview.update.*` (1 Key)
- `syllables_overview.index.*` (20+ Keys)
- `syllables_overview.update.*` (1 Key)
- `syllables_overview.fetch_wiktionary.*` (1 Key)
- `syllables_overview.fetch_all_wiktionary.*` (1 Key)

---

## Teil 6: Migrationen

| Migration | Zweck |
|-----------|-------|
| `20260416120000_fix_double_serialized_example_sentences` | Repariert doppelt-serialisierte JSONB-Daten in `words.example_sentences` |
| `20260416174402_create_bulk_edits` | Erstellt die `bulk_edits`-Tabelle fur Protokoll und Undo |
| `20260416184757_add_verified_fields_to_words` | Fugt `example_sentences_verified` und `syllables_verified` boolean-Spalten hinzu |
| `20260416191257_add_wiktionary_syllables_to_words` | Fugt `wiktionary_syllables` String-Spalte fur den Wiktionary-Cache hinzu |

---

## Teil 7: JavaScript / Stimulus Controller

| Controller | Targets | Zweck |
|-----------|---------|-------|
| `bulk_select_controller.js` | selectAll, checkbox, count | Select-All Checkbox mit Indeterminate-State und Zahler |
| `bulk_edit_form_controller.js` | fieldSelect, operationWrapper, valueInput | Zeigt/versteckt Formularfelder je nach gewahltem Feld |
| `tabs_controller.js` | tab, panel | Tab-Umschaltung mit aktiver Klasse und Panel-Sichtbarkeit |
| `wikidata_check_controller.js` | result | Asynchroner Wiktionary-Abgleich pro Zeile (Legacy, ersetzt durch DB-Cache) |

Alle Controller werden automatisch von Stimulus via `eagerLoadControllersFrom` geladen (keine manuelle Registrierung notig).

---

## Teil 8: Tests

### Neue Test-Dateien

| Datei | Tests | Abdeckung |
|-------|-------|-----------|
| `spec/services/bulk_edit_service_spec.rb` | 10 | HABTM add/remove, belongs_to set, boolean set, Undo fur alle Typen, Idempotenz, Already-undone-Error |
| `spec/features/bulk_edits_spec.rb` | 5 | Suche, Zuweisung via Service, Protokoll, Undo via Service, Autorisierung |
| `spec/features/example_sentences_overview_spec.rb` | 3 | Index, Suchfilter, Autorisierung |
| `spec/features/syllables_overview_spec.rb` | 4 | Index, Suchfilter, Silbenfilter, Autorisierung |
| `spec/services/wiktionary_syllable_service_spec.rb` | 2 | Erfolgreicher Lookup (mit WebMock), Fehlendes Wort |

**Gesamt: 536 Tests, 0 Failures**

---

## Teil 9: Technische Entscheidungen

### Warum eigenes BulkEdit-Model statt PaperTrail?
PaperTrail trackt Anderungen an der `words`-Tabelle selbst, aber **nicht** an HABTM-Join-Tables (`phenomenons_words`, `strategies_words`, `topics_words`). Da die Hauptoperationen HABTM-Zuweisungen sind, brauchen wir ein eigenes Model das Deltas speichert.

### Warum Deltas statt Snapshots?
Wenn wir vollstandige Assoziations-Snapshots speichern wurden, konnte ein Undo zwischenzeitliche Anderungen anderer Benutzer uberschreiben. Durch Delta-basierte Speicherung (nur die tatsachlich hinzugefugten/entfernten IDs) wird beim Undo nur das ruckgangig gemacht, was diese spezifische Operation geandert hat.

### Warum Wiktionary statt Wikidata SPARQL?
Wikidata hat die Property P5279 (Hyphenation), aber die Abdeckung fur deutsche Worter ist gering. Die deutsche Wiktionary hat eine deutlich bessere Abdeckung uber das `{{Worttrennung}}`-Template. Die MediaWiki-API ist einfacher zu nutzen als SPARQL.

### Warum DB-Cache statt Live-Requests?
Bei 5.000+ Wortern und 0.2s pro Request wurde ein Live-Abgleich Minuten dauern. Der DB-Cache (`wiktionary_syllables`-Spalte) ermoglicht sofortige Vergleiche. Der "Alle von Wiktionary abrufen"-Button fullt den Cache einmalig.

### Warum `rescue => e` statt spezifischer Exceptions?
Der Wiktionary-Service kann verschiedene Fehler werfen (Netzwerk, JSON-Parsing, Rate-Limit, unerwartete Antwortformate). Ein breiter Rescue mit Logging ist hier pragmatischer als spezifische Exception-Handler, da ein fehlgeschlagener Abruf fur ein einzelnes Wort den gesamten Batch nicht abbrechen soll.

### PreparedStatementCacheExpired
PostgreSQL invalidiert den Prepared-Statement-Cache nach Schema-Anderungen (neue Spalten). Der `BulkEditService` hat einen automatischen Retry-Mechanismus (`retry_on_cache_expired`) der die Transaction bei diesem Fehler einmal wiederholt.
