class Clipping < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  validates_presence_of :document_number

  def self.with_preloaded_articles
    clippings = all
    document_numbers = clippings.map{|c| c.document_number}

    clippings = map_articles_to_clipping(clippings, document_numbers)
    clippings
  end

  def self.create_from_cookie(document_numbers, user)
    return unless document_numbers.present?

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
    clippings.group_by(&:document_number).map do |document_number, clippings| 
      folder_array = clippings.map{|c| c.folder.present? ? c.folder.slug : "my-clippings"}.uniq
      { document_number => folder_array }
    end
  end

  def self.persist_document(document_number, user)
    clipping = Clipping.find_by_document_number_and_user_id(document_number, user.id)
    unless clipping.present?
      clipping = Clipping.new(:document_number => document_number,
                               :user_id         => user.id)
      clipping.save
    end
    clipping
  end

  # this is to ensure users can only find documents they have created
  # user should almost always be the current_user
  def self.find_by_user_and_id(user, id)
    scoped(:conditions => {:user_id => user.id, :id => id}).first
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
