class PopularDocument
  def self.popular(options={})
    popular_documents_by_comment = Comment.
      select('count(*) as comment_count, document_number').
      where('created_at >= ?', Date.current - 3.months).
      group(:document_number).
      order('comment_count DESC').
      limit(40)

    return [] unless popular_documents_by_comment.to_a.present?

    document_numbers = popular_documents_by_comment.map{|d| d.document_number}

    documents = Document.find_all(
      document_numbers,
      fields: [
        :comments_close_on,
        :document_number,
        :html_url,
        :publication_date,
        :regulations_dot_gov_info,
        :title,
        :type,
      ]
    ).results.compact

    popular_documents = []

    popular_documents_by_comment.each do |comment|
      popular_documents << self.new(
        comment.comment_count.value,
        comment.document_number,
        DocumentDecorator.decorate(
          documents.find{|d| d.document_number == comment.document_number}
        )
      )
    end

    popular_documents.reject{|d| d.document.object.nil?}
  end

  attr_reader :document, :document_number

  delegate :comments_close_on,
    :document_type,
    :html_url,
    :publication_date,
    :regulations_dot_gov_info,
    :title,
    :type,
    to: :@document

  def initialize(comment_count, document_number, document)
    @comment_count = comment_count
    @document = document
    @document_number = document_number
  end

  def comment_count
    if regulations_dot_gov_info &&
        regulations_dot_gov_info['comments_count'] &&
        regulations_dot_gov_info['comments_count'] > @comment_count
      regulations_dot_gov_info['comments_count']
    else
      @comment_count
    end
  end
end
