module CarouselHelper
  def carousel(highlights, options={})
    if highlights.size > 1
      document_numbers = highlights.map{|h| h.document_number}
      documents = Document.find_all(
        document_numbers,
        fields: [:agencies, :document_number, :publication_date, :type]
      )
    else
      documents = Document.find(
        highlights.first.document_number,
        fields: [:agencies, :document_number, :publication_date, :type]
      )
    end

    render partial: 'components/carousel', locals: {
      highlights: highlights,
      documents: DocumentDecorator.decorate_collection(
        Array(documents)
      ),
      html_options: options.fetch(:html_options){ {} },
      image_size: options.fetch(:image_size){ "large" }
    }
  end
end
