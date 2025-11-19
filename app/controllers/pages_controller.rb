class PagesController < PublicController
  def imprint
  end

  def navigation
  end

  private

  def page_title
    case action_name
    when "navigation"
      t("navigation.page_title")
    when "imprint"
      t("pages.imprint.title")
    end
  end
  helper_method :page_title
end
