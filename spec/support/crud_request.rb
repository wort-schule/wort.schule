# frozen_string_literal: true

RSpec.shared_examples "CRUD request spec" do |model_class, valid_attrs, invalid_attrs, update_attrs = nil|
  let(:admin) { create :admin }
  let(:resource) { create model_class.model_name.singular.to_sym, valid_attrs }
  let(:model_name) { model_class.model_name.singular }
  let(:plural_name) { model_class.model_name.plural }
  let(:resource_path) { public_send(:"#{model_name}_path", resource) }
  let(:resources_path) { public_send(:"#{plural_name}_path") }
  let(:new_resource_path) { public_send(:"new_#{model_name}_path") }
  let(:edit_resource_path) { public_send(:"edit_#{model_name}_path", resource) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:resource1) { create model_class.model_name.singular.to_sym, valid_attrs }
    let!(:resource2) { create model_class.model_name.singular.to_sym, valid_attrs }

    it "renders the index template" do
      get resources_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "renders the show template" do
      get resource_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "renders the new template" do
      get new_resource_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new #{model_class.name}" do
        expect {
          post resources_path, params: {model_name => valid_attrs}
        }.to change(model_class, :count).by(1)
      end

      it "redirects to the created resource" do
        post resources_path, params: {model_name => valid_attrs}
        expect(response).to redirect_to(model_class.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new #{model_class.name}" do
        expect {
          post resources_path, params: {model_name => invalid_attrs}
        }.not_to change(model_class, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post resources_path, params: {model_name => invalid_attrs}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit" do
    it "renders the edit template" do
      get edit_resource_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      let(:new_attributes) { update_attrs || valid_attrs }

      it "updates the resource" do
        patch resource_path, params: {model_name => new_attributes}
        resource.reload
        new_attributes.each do |key, value|
          expect(resource.send(key)).to eq(value)
        end
      end

      it "redirects to the resource" do
        patch resource_path, params: {model_name => new_attributes}
        expect(response).to redirect_to(resource)
      end
    end

    context "with invalid parameters" do
      it "does not update the resource" do
        original_attrs = valid_attrs.keys.map { |key| [key, resource.send(key)] }.to_h
        patch resource_path, params: {model_name => invalid_attrs}
        resource.reload
        original_attrs.each do |key, value|
          expect(resource.send(key)).to eq(value)
        end
      end

      it "renders the edit template with unprocessable_entity status" do
        patch resource_path, params: {model_name => invalid_attrs}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:resource_to_delete) { create model_class.model_name.singular.to_sym, valid_attrs }

    it "destroys the resource" do
      expect {
        delete public_send(:"#{model_name}_path", resource_to_delete)
      }.to change(model_class, :count).by(-1)
    end

    it "redirects to the resources list" do
      delete public_send(:"#{model_name}_path", resource_to_delete)
      expect(response).to redirect_to(resources_path)
    end
  end
end
