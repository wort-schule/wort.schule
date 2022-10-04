namespace :word_images do
  desc "Imports images of words"
  task :import, [:image_directory] => [:environment] do |task, args|
    directory = args[:image_directory]

    raise "You need to specify an import directory: bin/rails 'word_images:import[db/seeds/word_images]'" if directory.blank?

    ignored_patterns = [
      "4c",
      "4C",
      "korr",
      /\(.+\)/,
      /\.[^.]+$/,
      /\d/
    ]

    # Some filenames need to be mapped to other words. We don't change the
    # filename itself because that will only get us in trouble if we get new or
    # updated images.
    mapping = {
      "Seilchen springen" => "springen",
      "Schweiß Schwitzen schweißtreibend" => nil,
      "Spatz Sperling" => nil,
      "curling" => "Curling",
      "Tanz tanzen" => nil,
      "Angst änstlich" => nil,
      "Anschaeun angucken" => nil,
      "Bauer Schach" => "Bauer",
      "Ecke Fußball" => "Ecke",
      "Rote Karte Fußball" => "rote Karte",
      "gelbe Karte Fußball" => "gelbe Karte"
    }

    # For unknown words, we need to know what kind of words they are.
    unknown_words = [
      ["Adrenalin", Noun, nil],
      ["Albino", Noun, nil],
      ["Alligator", Noun, nil],
      ["Alpaka", Noun, nil],
      ["Alphatier", Noun, nil],
      ["American Football", Noun, nil],
      ["Amphibien", Noun, nil],
      ["Anatomie", Noun, nil],
      ["Aportieren", Verb, nil],
      ["Augen", Noun, nil],
      ["Ballspiele", Noun, nil],
      ["Baseballfeld", Noun, nil],
      ["Baseballstadion", Noun, nil],
      ["Basketballkorb", Noun, nil],
      ["Basketballspiel", Noun, nil],
      ["Bauer", Noun, "Schach"],
      ["Baumpython", Noun, nil],
      ["Beisszähne", Noun, nil],
      ["Berge", Noun, nil],
      ["Berglandschaft", Noun, nil],
      ["Biathlon", Noun, nil],
      ["Biene", Noun, nil],
      ["Blumenvase", Noun, nil],
      ["Blumenwiese", Noun, nil],
      ["Bobfahren", Noun, nil],
      ["Bolzplatz", Noun, nil],
      ["Boxring", Noun, nil],
      ["Bär", Noun, nil],
      ["Cardio", Noun, nil],
      ["Crickett", Noun, nil],
      ["DNA", Noun, nil],
      ["Ecke", Noun, "Fußball"],
      ["Egel", Noun, nil],
      ["Eiweiss", Noun, nil],
      ["Enten", Noun, nil],
      ["Finken", Noun, nil],
      ["Fischfutter", Noun, nil],
      ["Fitnessstudio", Noun, nil],
      ["Flughörnchen", Noun, nil],
      ["Flöhe", Noun, nil],
      ["Footballfeld", Noun, nil],
      ["Fressnapf", Noun, nil],
      ["Jahrgangsstufe", Noun, nil],
      ["Langlauf", Noun, nil],
      ["Leichtathletikstadion", Noun, nil],
      ["Medaillen", Noun, nil],
      ["Pferdefleisch", Noun, nil],
      ["Proteinshake", Noun, nil],
      ["Putzkasten", Noun, nil],
      ["Rangordnung", Noun, nil],
      ["Rote Karte", Noun, "Fußball"],
      ["Rückentraining", Noun, nil],
      ["Schimpanse", Noun, nil],
      ["Schulleiterin", Noun, nil],
      ["Siebenkampf", Noun, nil],
      ["Skeleton", Noun, nil],
      ["Skilaufen", Noun, nil],
      ["Skispringen", Noun, nil],
      ["Smartboard", Noun, nil],
      ["Snowboarden", Noun, nil],
      ["Sportanzug", Noun, nil],
      ["Squashball", Noun, nil],
      ["Stollenschuhe", Noun, nil],
      ["Tenniscourt", Noun, nil],
      ["Training nach plan", Noun, nil],
      ["Trickot", Noun, nil],
      ["Versprechen", Noun, nil],
      ["Vogelbauer", Noun, nil],
      ["Waschbär", Noun, nil],
      ["Weitwurf", Noun, nil],
      ["Weltmeisterin", Noun, nil],
      ["Zehnkampf", Noun, nil],
      ["agressiv", Adjective, nil],
      ["beschützen", Verb, nil],
      ["clever", Adjective, nil],
      ["Curling", Noun, nil],
      ["erfreulich", Adjective, nil],
      ["gelbe Karte", Noun, "Fußball"],
      ["rote Karte", Noun, "Fußball"],
      ["schwitzig", Adjective, nil],
      ["zutraulich", Adjective, nil],
      ["schweißtreibend", Adjective, nil]
    ]

    missing_words = []

    Dir["#{directory}/*"].each do |filename|
      basename = File.basename filename

      word_text = ignored_patterns.reduce(basename) do |name, pattern|
        name.gsub(pattern, "")
      end.strip
      word_text = mapping[word_text] if mapping.has_key?(word_text)

      if word_text.blank?
        puts "[IGNO] #{basename}"
        next
      end

      word = Word.where("name ILIKE ?", word_text).first

      if word.present?
        state = " OK "
      else
        state = " NEW"
        word_info = unknown_words.find { |info| info[0] == word_text }

        if word_info.present?
          word_text, klass, topic = word_info

          word = klass.create(name: word_text)

          if topic.present?
            topic = Topic.find_or_create_by(name: topic)
            word.topics << topic
          end
        else
          state = "MISS"
          missing_words << word_text
        end
      end

      if word.present?
        word.image.attach(
          io: StringIO.new(File.read(filename)),
          filename: filename
        )
      end

      puts "[#{state}] #{basename} | #{word_text}"
    end

    puts
    puts
    puts "Missing words:"
    puts missing_words.join(", ")
  end
end
