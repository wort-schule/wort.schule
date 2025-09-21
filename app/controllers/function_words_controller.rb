# frozen_string_literal: true

class FunctionWordsController < WordTypeController
  def index
    @function_words = @function_words.order("words.name").page(params[:page])
  end

  private

  def resource_params
    function_word_params
  end

  def filtered_words
    @function_words.order("words.name").page(params[:page])
  end

  def function_word_params
    params.require(:function_word).permit(
      :name, :function_type, :syllables, :written_syllables
    )
  end
end
