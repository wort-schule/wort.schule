# Minimal replacement for active_record_extended's `.union(...)` helper.
# active_record_extended is capped at activerecord < 8.1, so we provide just
# the union flavor we use in app/models/learning_group.rb and
# app/controllers/concerns/word_filter.rb. Drop this file the day Rails ships
# native `Relation#union` or active_record_extended supports 8.1+.

module ActiveRecordUnionRelation
  def union(*relations)
    sqls = relations.compact.map { |r| r.respond_to?(:to_sql) ? r.to_sql : r.to_s }
    return all if sqls.empty?

    union_sql = sqls.map { |s| "(#{s})" }.join(" UNION ")
    klass.from("(#{union_sql}) AS #{klass.table_name}")
  end
end

module ActiveRecordUnionBase
  def union(*relations)
    all.union(*relations)
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(ActiveRecordUnionRelation)
  ActiveRecord::Base.singleton_class.include(ActiveRecordUnionBase)
end
