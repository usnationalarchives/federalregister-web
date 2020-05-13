class PopularDocument

  POPULAR_DOCUMENT_COUNT = 40
  DOCUMENT_CUTOFF        = 90.days
  def self.popular(options={})
    results = Document.search(
      conditions: {
        publication_date: {gte: Date.current - DOCUMENT_CUTOFF}
      },
      fields: %w(document_number html_url page_views type title),
      per_page: 1000,
    )

    documents_by_document_number = {}
    while results do
      results.each{|doc| documents_by_document_number[doc.document_number] = doc }
      results = results.next
    end

    comment_counts_by_document_number = Comment.
      select('count(*) AS comment_count, document_number').
      where(document_number: documents_by_document_number.keys).
      group(:document_number).
      each_with_object(Hash.new) do |comment, hsh|
        hsh[comment.document_number] = comment.attributes['comment_count']
      end

    comment_counts_by_document_number.
      sort_by{|document_number, comment_count| (comment_count * documents_by_document_number.fetch(document_number).page_views.fetch(:count).to_i ) }.
      first(POPULAR_DOCUMENT_COUNT).
      map do |document_number, comment_count|
        self.new(
          comment_count,
          document_number,
          DocumentDecorator.decorate(
            documents_by_document_number.fetch(document_number)
          )
        )
      end
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
