class Clipping < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  validates_presence_of :document_number

  def self.with_preloaded_articles
    clippings = all
    document_numbers = clippings.map{|c| c.document_number}
    
    return unless clippings.present? && document_numbers.present?

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

  def self.all_preloaded_from_cookie(cookie_data)
    document_numbers = retrieve_document_numbers(cookie_data)
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

  def self.persist_document(user, document_number, folder_name)
    if folder_name == 'my-clippings'
      folder = nil
      clipping = Clipping.find_by_document_number_and_user_id(document_number, user.id)
    else
      folder = Folder.find_by_creator_id_and_slug(user.id, folder_name)
      clipping = Clipping.find_by_document_number_and_user_id_and_folder_id(document_number, user.id, folder.id)
    end
    unless clipping.present?
      clipping = Clipping.new(:document_number => document_number,
                              :user_id         => user.id,
                              :folder          => folder)
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

  def self.retrieve_document_numbers(cookie_data)
    document_number_array = JSON.parse(cookie_data)
    document_numbers = []
    document_number_array.each do |doc_hash| 
      doc_hash.each_key{|doc_num| document_numbers << doc_num }
    end
    document_numbers
  end
end
