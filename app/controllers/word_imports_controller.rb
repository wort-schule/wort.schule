# frozen_string_literal: true

class WordImportsController < ApplicationController
  authorize_resource :word_import, class: false

  def new
    @word_import = Forms::WordImport.new
  end

  def create
    @word_import = Forms::WordImport.new(word_import_params)

    if @word_import.valid?
      @count = Import::Csv.new(csv: @word_import.csv).call
      render :create, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def page_title
    t("word_imports.#{action_name}.title")
  end
  helper_method :page_title

  def word_import_params
    params
      .require(:word_import)
      .permit(:csv_file)
  end
end
