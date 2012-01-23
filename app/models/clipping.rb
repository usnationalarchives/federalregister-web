class Clipping < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :document_number

  def self.with_preloaded_articles
    clippings = all
    document_numbers = clippings.map{|c| c.document_number}

    clippings = map_articles_to_clipping(clippings, document_numbers)
    clippings
  end

  def self.create_from_cookie(document_numbers, user)
    document_numbers = JSON.parse(document_numbers)
    document_numbers.each do |document_number, folder|
      self.persist_document(document_number, user)
    end
  end

  def self.all_preloaded_from_cookie(document_number_hash)
    document_numbers = document_number_hash.map{|doc_num, folders| doc_num }
    clippings = document_numbers.map{|doc_num| Clipping.new(:document_number => doc_num) }
    clippings = map_articles_to_clipping(clippings, document_numbers)
    clippings
  end

  def self.map_articles_to_clipping(clippings, document_numbers)
    articles = document_numbers.size > 1 ? FederalRegister::Article.find_all(document_numbers) : [FederalRegister::Article.find(document_numbers.first)]

    clippings.map do |clipping|
      clipping.article = articles.find{|a| a.document_number == clipping.document_number}
      clipping
    end

    clippings
  end

  def self.for_javascript
    clippings = all
    clippings.map{|c| {c.document_number => [0]} }
  end

  def self.persist_document(document_number, user)
    clipping = Clipping.find_by_document_number_and_user_id(document_number, user.id)
    unless clipping
      clipping = Clipping.new(:document_number => document_number,
                               :user_id         => user.id)
      clipping.save
    end
    clipping
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
