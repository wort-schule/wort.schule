# frozen_string_literal: true

# Base controller for standard CRUD operations on resources.
# Provides common patterns for index, show, new, create, edit, update, and destroy actions.
#
# Usage:
#   class PrefixesController < CrudResourceController
#     private
#
#     def permitted_attributes
#       [:name, :prefix_type, :separable, :inseparable]
#     end
#   end
class CrudResourceController < ApplicationController
  include CrudActions
  load_and_authorize_resource
end
