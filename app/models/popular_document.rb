class PopularDocument

  POPULAR_DOCUMENT_COUNT = 8
  DOCUMENT_CUTOFF        = 30.days
  def self.popular(options={})
    cutoff_date = Date.current - DOCUMENT_CUTOFF
    comment_counts_by_document_number = Comment.
      where("created_at > '#{cutoff_date.to_s(:iso)}'").
      group(:document_number).
      count
    document_numbers = comment_counts_by_document_number.
      sort_by {|doc_number, count| count}.
      reverse. #eg [['2022-27931',997],...]
      map{|x| x.first}. 
      first(POPULAR_DOCUMENT_COUNT)
    
    if document_numbers.present?
      Document.
        find_all(document_numbers).
        map do |document, comment_count|
          doc_number = document.document_number
          self.new(
            comment_counts_by_document_number.fetch(doc_number),
            doc_number,
            DocumentDecorator.decorate(document)
          )
        end.
        sort_by{|x| comment_counts_by_document_number.fetch(x.document_number) }.
        reverse
    else
      []
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
