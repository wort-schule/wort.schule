# Minimal replacement for active_record_extended's `.union(...)` helper.
# active_record_extended 3.4.0 caps activerecord < 8.1, so we provide just
# the union flavor used in app/models/learning_group.rb and
# app/controllers/concerns/word_filter.rb.

module ActiveRecordUnionRelation
  def union(*relations)
    relations = relations.compact
    return all if relations.empty?

    relations.each do |r|
      raise ArgumentError, "union expects ActiveRecord::Relation, got #{r.class}" unless r.respond_to?(:to_sql)
    end

    union_sql = relations.map { |r| "(#{r.to_sql})" }.join(" UNION ")
    klass.from("(#{union_sql}) #{klass.table_name}")
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
