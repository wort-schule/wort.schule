module FilterHelper
  def filter_text_field(form, attribute, **input_options)
    form_attribute = "filter_#{attribute}"

    inline = input_options.delete(:inline)
    input_field = form.text_field form_attribute, input_options.deep_merge(data: {action: "input->form-submission#search", "turbo-permanent": true})

    return input_field if inline

    content_tag :div, class: "input grow" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat input_field
    end
  end

  def filter_select_field(form, attribute, collection:)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat form.select form_attribute, collection, {include_blank: true, selected: @filterrific.public_send(form_attribute)}, data: {action: "input->form-submission#search"}, class: "w-full", disabled: collection.empty?
    end
  end

  def filter_select_field_with_and_or(form, attribute, collection:)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat(content_tag(:div, class: "flex gap-2 items-start") do
        concat(form.fields_for(form_attribute) do |fields|
          concat fields.select :conjunction, [[I18n.t("filter.and"), "and"], [I18n.t("filter.or"), "or"]], {}, data: {action: "input->form-submission#search"}, style: "flex-shrink: 3"
          concat fields.select attribute, collection, {include_blank: true, selected: @filterrific.public_send(form_attribute)&.dig(attribute)}, multiple: true, data: {action: "input->form-submission#search", controller: "select"}, class: "select default-input w-full flex-grow", style: "flex-shrink: 1"
        end)
      end)
    end
  end

  def filter_check_box_field(form, attribute)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input boolean" do
      form.label form_attribute, class: "boolean checkbox" do
        concat form.check_box form_attribute, data: {action: "input->form-submission#search"}, class: "boolean default-input"
        concat content_tag :span, I18n.t("filter.#{attribute}")
      end
    end
  end
end
