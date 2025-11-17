# frozen_string_literal: true

module NavigationHelper
  def user_menu_link(active, name = nil, options = nil, html_options = nil)
    html_options ||= {}

    html_options[:class] = if active
      "#{html_options.fetch(:class, "")} block px-3 py-2 rounded-md text-base font-medium bg-primary-selected text-white md:bg-primary"
    else
      "#{html_options.fetch(:class, "")} block px-3 py-2 rounded-md text-base font-medium text-gray-100 md:text-gray-700 md:hover:bg-gray-100"
    end

    link_to name, options, html_options
  end

  def navigation_link(active, name = nil, options = nil, html_options = nil)
    html_options ||= {}

    if active
      html_options[:class] = "#{html_options.fetch(:class, "")} navigation active"
      html_options[:"aria-current"] = "page"
    else
      html_options[:class] = "#{html_options.fetch(:class, "")} navigation"
    end

    link_to name, options, html_options
  end

  def dropdown_link(klass)
    return unless can?(:index, klass)

    link_to klass.model_name.human(count: 2), [klass.model_name.plural.to_sym], data: {action: "click->dropdown#toggle"}, class: "no-underline block px-8 py-3 text-gray-300 hover:bg-primary whitespace-nowrap"
  end

  def has_navigation_access?
    # For anonymous users, only show public content
    if current_user.blank?
      can?(:read, Noun) || can?(:read, Verb) || can?(:read, Adjective) ||
        can?(:read, FunctionWord) || can?(:read, Topic) ||
        can?(:read, Keyword) ||
        [FunctionWord, Topic, Prefix, Postfix, Phenomenon, Strategy, CompoundInterfix, CompoundPreconfix, CompoundPostconfix, CompoundPhonemReduction, CompoundVocalalternation].any? { |klass| can? :read, klass } ||
        can?(:read, :word_images)
    else
      # For logged in users, show all accessible content
      can?(:create, Noun) || can?(:create, Verb) || can?(:create, Adjective) ||
        can?(:manage, :word_import) || can?(:manage, :word_images) ||
        [Theme, List].any? { |klass| can? :read, klass } ||
        can?(:read, Source) || can?(:index, WordViewSetting) || can?(:read, Keyword) ||
        can?(:manage, :review) || can?(:read, ImageRequest) ||
        can?(:manage, LlmPrompt) || can?(:manage, LlmService) || can?(:manage, :llm_enrichment) ||
        [FunctionWord, Topic, Prefix, Postfix, Phenomenon, Strategy, CompoundInterfix, CompoundPreconfix, CompoundPostconfix, CompoundPhonemReduction, CompoundVocalalternation].any? { |klass| can? :read, klass } ||
        can?(:index, User) || can?(:index, LearningGroup)
    end
  end
end
