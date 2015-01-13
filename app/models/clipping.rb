class Clipping < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_protected []

  belongs_to :user
  belongs_to :folder

  validates_presence_of :document_number

  def self.with_preloaded_articles
    clippings = all

    document_numbers = clippings.map{|c| c.document_number}

    return unless clippings.present? && document_numbers.present?

    clippings = map_documents_to_clipping(clippings, document_numbers)
    clippings
  end

  def self.create_from_cookie(document_numbers, user)
    return unless document_numbers.present?

    document_numbers = JSON.parse(document_numbers)
    document_numbers.each do |doc_hash|
      doc_hash.each_pair do |document_number, folders|
        self.persist_document(user, document_number, folders[0])
      end
    end
    user.update_attribute(:new_clippings_count, document_numbers.count)
  end

  def self.all_preloaded_from_cookie(cookie_data)
    document_numbers = retrieve_document_numbers(cookie_data)
    clippings = document_numbers.map{|doc_num| Clipping.new(:document_number => doc_num) }
    clippings = map_articles_to_clipping(clippings, document_numbers)
    clippings
  end

  def self.map_documents_to_clipping(clippings, document_numbers)
    begin
      fields = ["agencies",
                "citation",
                "comments_close_on",
                "corrections",
                "correction_of",
                "docket_ids",
                "document_number",
                "effective_on",
                "end_page",
                "executive_order_number",
                "html_url",
                "president",
                "publication_date",
                "signing_date",
                "start_page",
                "subtype",
                "title",
                "type"]

      documents = FederalRegister::Document.find_all(
        document_numbers,
        :fields => fields
      )

      clippings.select do |clipping|
        document = documents.find{|d| d.document_number == clipping.document_number}
        if document
          clipping.document = document
        else
          false
        end
      end
    rescue FederalRegister::Article::InvalidDocumentNumber
      []
    rescue FederalRegister::Client::RecordNotFound
      []
    end
  end

  def self.persist_document(user, document_number, folder_name)
    if folder_name == 'my-clippings'
      folder = nil
      clipping = Clipping.where(
        document_number: document_number,
        user_id: user.id,
        folder_id: nil
      ).first
    else
      folder = Folder.where(
        creator_id: user.id,
        slug: folder_name
      ).first
      clipping = Clipping.where(
        document_number: document_number,
        user_id: user.id,
        folder_id: folder.id
      ).first
    end
    unless clipping.present?
      clipping = Clipping.new(
        document_number: document_number,
        user_id: user.id,
        folder: folder
      )
      clipping.save
    end
    clipping
  end

  # this is to ensure users can only find documents they have created
  # user should almost always be the current_user
  def self.find_by_user_and_id(user, id)
    scoped(:conditions => {:user_id => user.id, :id => id}).first
  end

  def document
    if document_number
      @document ||= FederalRegister::Document.find(document_number)
    end
  end

  def document=(document)
    self.document_number = document.try(:document_number)
    @document = document
  end

  def self.retrieve_document_numbers(cookie_data)
    document_number_array = JSON.parse(cookie_data)
    document_numbers = []
    document_number_array.each do |doc_hash|
      doc_hash.each_key{|doc_num| document_numbers << doc_num }
    end
    document_numbers
  end

  def comment
    return if user.nil?

    comment = user.comments.where(
      document_number: self.document_number
    ).first

    if comment
      CommentDecorator.decorate(comment)
    else
      comment
    end
  end
end
