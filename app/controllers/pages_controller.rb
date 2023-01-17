class PagesController < PublicController
  def imprint
  end


  def word_index
  end


  def word_index_letter
    @letter = params[:letter]
    @words = Word.where("name ILIKE ?", "#{@letter}%").order(:name).page(params[:page])
  end
end
