# frozen_string_literal: true

module KaminariHelper
  def paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
    output = number_with_delimiter scope.total_count

    options[:total_pages] ||= scope.total_pages
    options.reverse_merge! current_page: scope.current_page, per_page: scope.limit_value, remote: false

    paginator = paginator_class.new (template || self), **options

    content_tag :div, class: "text-xs text-gray-500 flex flex-col md:flex-row gap-2 md:items-center" do
      concat paginator.to_s
      concat "#{output} #{scope.model_name.human(count: scope.total_count)}"
    end
  end
end
