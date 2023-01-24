class SeoController < PublicController
  def word_index
    @letter = params[:letter] || 'a'
    @words = Word.where("name ILIKE ?", "#{@letter}%").order("LOWER(name)").page(params[:page])
  end
end
