# frozen_string_literal: true

Rails.application.config.to_prepare do
  Dir["app/liquid/**/*.rb"].each do |filename|
    tag_name = File.basename(filename).gsub(/\.rb$/, "")
    class_name = tag_name.camelize

    # Using Template.register_tag for now - will address deprecation in future Liquid update
    Liquid::Template.register_tag(tag_name, class_name.constantize)
  end
end
