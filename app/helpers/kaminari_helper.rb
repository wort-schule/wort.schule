# frozen_string_literal: true

module KaminariHelper
  def paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
    output = number_with_delimiter scope.total_count

    # Handle both ActiveRecord relations and PaginatableArrays
    model_name = if options.key?(:model_name)
      options.delete(:model_name)
    elsif scope.respond_to?(:model_name)
      "activerecord.models.#{scope.model_name.i18n_key}"
    end

    options[:total_pages] ||= scope.total_pages
    options.reverse_merge! current_page: scope.current_page, per_page: scope.limit_value, remote: false

    paginator = paginator_class.new (template || self), **options

    content_tag :div, class: "text-xs text-gray-500 flex flex-col md:flex-row gap-2 md:items-center" do
      concat paginator.to_s
      if model_name
        concat "#{output} #{I18n.t(model_name, count: scope.total_count)}"
      end
    end
  end
end
