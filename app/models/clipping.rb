class Clipping < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :document_number

  def self.with_preloaded_articles
    clippings = all
    document_numbers = clippings.map{|c| c.document_number}
    articles = document_numbers.size > 1 ? FederalRegister::Article.find_all(document_numbers) : [FederalRegister::Article.find(document_numbers.first)]

    clippings.map do |clipping|
      clipping.article = articles.find{|a| a.document_number == clipping.document_number}
      clipping
    end
  end

  def article
    if document_number
      @article ||= FederalRegister::Article.find(document_number)
    end
  end

  def article=(article)
    self.document_number = article.try(:document_number)
    @article = article
  end
end
