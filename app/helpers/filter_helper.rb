module FilterHelper
  def filter_text_field(form, attribute, **input_options)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat form.text_field form_attribute, input_options.deep_merge(data: {action: "input->form-submission#search"})
    end
  end

  def filter_select_field(form, attribute, collection:)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat form.select form_attribute, collection, {include_blank: true, selected: @filterrific.public_send(form_attribute)}, data: {action: "input->form-submission#search"}, class: "w-full"
    end
  end

  def filter_select_field_with_and_or(form, attribute, collection:)
    form_attribute = "filter_#{attribute}"

    content_tag :div, class: "input" do
      concat form.label form_attribute, I18n.t("filter.#{attribute}")
      concat(form.fields_for(form_attribute) do |fields|
        concat fields.select :conjunction, [[I18n.t("filter.and"), "and"], [I18n.t("filter.or"), "or"]], {}, data: {action: "input->form-submission#search"}
        concat fields.select attribute, collection, {include_blank: true, selected: @filterrific.public_send(form_attribute)}, multiple: true, data: {action: "input->form-submission#search", controller: "select"}, class: "select default-input w-full flex-grow"
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
