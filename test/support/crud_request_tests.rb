# frozen_string_literal: true

# Replaces the RSpec.shared_examples "CRUD request spec".
#
# Usage:
#
#   class CompoundsControllerCrudTest < ActionDispatch::IntegrationTest
#     extend CrudRequestTests
#     crud_request_tests_for(
#       Compound,
#       valid_attrs: { name: "x" },
#       invalid_attrs: { name: "" },
#       update_attrs: { name: "y" }   # optional, defaults to valid_attrs
#     )
#   end
module CrudRequestTests
  def crud_request_tests_for(model_class, valid_attrs:, invalid_attrs:, update_attrs: nil)
    singular = model_class.model_name.singular
    plural = model_class.model_name.plural
    update_payload = update_attrs || valid_attrs

    setup do
      sign_in create(:admin)
    end

    test "GET #index renders the index template" do
      create(singular.to_sym, valid_attrs)
      create(singular.to_sym, valid_attrs)

      get public_send(:"#{plural}_path")

      assert_response :success
    end

    test "GET #show renders the show template" do
      resource = create(singular.to_sym, valid_attrs)

      get public_send(:"#{singular}_path", resource)

      assert_response :success
    end

    test "GET #new renders the new template" do
      get public_send(:"new_#{singular}_path")

      assert_response :success
    end

    test "POST #create with valid params creates a new #{model_class.name}" do
      assert_difference -> { model_class.count }, +1 do
        post public_send(:"#{plural}_path"), params: {singular => valid_attrs}
      end
    end

    test "POST #create with valid params redirects to the created resource" do
      post public_send(:"#{plural}_path"), params: {singular => valid_attrs}

      assert_redirected_to model_class.last
    end

    test "POST #create with invalid params does not create a new #{model_class.name}" do
      assert_no_difference -> { model_class.count } do
        post public_send(:"#{plural}_path"), params: {singular => invalid_attrs}
      end
    end

    test "POST #create with invalid params responds with unprocessable_entity" do
      post public_send(:"#{plural}_path"), params: {singular => invalid_attrs}

      assert_response :unprocessable_entity
    end

    test "GET #edit renders the edit template" do
      resource = create(singular.to_sym, valid_attrs)

      get public_send(:"edit_#{singular}_path", resource)

      assert_response :success
    end

    test "PATCH #update with valid params updates the resource" do
      resource = create(singular.to_sym, valid_attrs)

      patch public_send(:"#{singular}_path", resource), params: {singular => update_payload}
      resource.reload

      update_payload.each do |key, value|
        assert_equal value, resource.send(key)
      end
    end

    test "PATCH #update with valid params redirects to the resource" do
      resource = create(singular.to_sym, valid_attrs)

      patch public_send(:"#{singular}_path", resource), params: {singular => update_payload}

      assert_redirected_to resource
    end

    test "PATCH #update with invalid params does not change the resource" do
      resource = create(singular.to_sym, valid_attrs)
      original_attrs = valid_attrs.transform_values { |_| nil }.merge(
        valid_attrs.keys.map { |k| [k, resource.send(k)] }.to_h
      )

      patch public_send(:"#{singular}_path", resource), params: {singular => invalid_attrs}
      resource.reload

      original_attrs.each do |key, value|
        assert_equal value, resource.send(key)
      end
    end

    test "PATCH #update with invalid params responds with unprocessable_entity" do
      resource = create(singular.to_sym, valid_attrs)

      patch public_send(:"#{singular}_path", resource), params: {singular => invalid_attrs}

      assert_response :unprocessable_entity
    end

    test "DELETE #destroy destroys the resource" do
      resource = create(singular.to_sym, valid_attrs)

      assert_difference -> { model_class.count }, -1 do
        delete public_send(:"#{singular}_path", resource)
      end
    end

    test "DELETE #destroy redirects to the resources list" do
      resource = create(singular.to_sym, valid_attrs)

      delete public_send(:"#{singular}_path", resource)

      assert_redirected_to public_send(:"#{plural}_path")
    end
  end
end
