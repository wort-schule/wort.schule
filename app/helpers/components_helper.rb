# frozen_string_literal: true

module ComponentsHelper
  def title_with_actions(title, &block)
    content_tag :div, class: "flex flex-col md:flex-row md:justify-between items-start md:items-center title px-4 md:px-0 gap-4" do
      concat content_tag :h1, title
      concat content_tag :div, class: "flex flex-wrap justify-end gap-2", &block if block
    end
  end

  def box(options = {}, &block)
    padding = options[:padding].nil? ? true : options.delete(:padding)
    classes = options.delete(:class) || ""

    classes += padding ? " px-4 py-5 sm:px-6" : ""

    content_tag "div", options.merge(class: "box bg-white shadow rounded-3xl #{classes}") do
      yield
    end
  end

  def box_title(title, options = {})
    padding = options[:padding].nil? ? true : options[:padding]
    padding_classes = padding ? "px-4 py-5 sm:px-6" : ""
    heading = options[:heading].presence || "h1"

    content_tag :div, class: "#{padding_classes} flex flex-col md:flex-row md:justify-between items-center" do
      concat content_tag heading, title, class: "mt-0 text-lg leading-6 font-medium text-gray-900"
      yield if block_given?
    end
  end

  def box_description_list
    content_tag "div", class: "border-t border-gray-200" do
      content_tag "dl", class: "striped" do
        yield BoxDescriptionList.new
      end
    end
  end

  def box_content
    content_tag :div, class: "px-4 py-5 bg-white space-y-6 sm:p-6" do
      yield
    end
  end

  def box_footer
    content_tag :div, class: "px-4 py-3 bg-gray-50 text-right sm:px-6" do
      yield
    end
  end

  def index_grid
    content_tag "div", class: "grid md:grid-cols-3 my-6 gap-4" do
      yield
    end
  end

  def two_column_card(title, description, first: false)
    content = capture do
      yield
    end

    render layout: "components/two_column_card", locals: {title:, description:, first:} do
      content
    end
  end

  def link_if(condition, path, options = {}, &block)
    content = capture do
      yield
    end

    if condition
      link_to path, options do
        content
      end
    else
      content
    end
  end

  def edit_button(path)
    link_to path, class: "button" do
      content_tag :div, class: "flex gap-2" do
        concat heroicon "pencil"
        concat t("actions.change")
      end
    end
  end

  def delete_button(path)
    button_to path, class: "button", method: :delete do
      content_tag :div, class: "flex gap-2" do
        concat heroicon "trash"
        concat t("actions.delete")
      end
    end
  end

  def cancel_button(path)
    link_to t("actions.cancel"), path, class: "button"
  end
end
