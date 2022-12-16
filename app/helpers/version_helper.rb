# frozen_string_literal: true

module VersionHelper
  def versions_with_changes(versions)
    versions.select { |version| version.changeset.present? }
  end

  def changed_by(version)
    user = User.find_by(id: version.whodunnit)
    username = user&.full_name.presence || user&.email || I18n.t("shared.unknown")
    datetime = I18n.l version.created_at
    action = I18n.t("shared.versions.actions.#{version.event}")

    I18n.t("shared.versions.changed_by", action:, username:, datetime:)
  end
end
