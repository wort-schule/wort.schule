# frozen_string_literal: true

# Alt texts for word images (issue #771, WCAG 1.1.1).
#
# The column was already present in db/schema.rb since commit 34177e6 without
# any migration creating it: it got dumped there from a drifted development
# database. CI builds its database with db:schema:load and therefore had the
# column, production runs db:migrate and did not. Code touching the attribute
# would have passed CI and raised in production.
#
# if_not_exists keeps this migration safe on the development databases that
# already carry the stray column.
class AddImageAltTextToWords < ActiveRecord::Migration[8.1]
  def change
    add_column :words, :image_alt_text, :string, if_not_exists: true
  end
end
