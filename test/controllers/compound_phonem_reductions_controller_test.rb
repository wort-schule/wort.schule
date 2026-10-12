# frozen_string_literal: true

require "test_helper"

class CompoundPhonemReductionsControllerTest < ActionDispatch::IntegrationTest
  extend CrudRequestTests

  crud_request_tests_for(
    CompoundPhonemReduction,
    valid_attrs: {name: "i→ø"},
    invalid_attrs: {name: ""},
    update_attrs: {name: "o→ø"}
  )

  test "DELETE #destroy keeps a phoneme reduction that is used in a word and says why" do
    reduction = create(:compound_phonem_reduction)
    create(:compound_entity, part: reduction)

    assert_no_difference -> { CompoundPhonemReduction.count } do
      delete compound_phonem_reduction_path(reduction)
    end

    assert_redirected_to compound_phonem_reductions_path
    assert_includes flash[:alert], I18n.t("activerecord.errors.models.compound_phonem_reduction.restrict_dependent_destroy.has_many")
  end
end
