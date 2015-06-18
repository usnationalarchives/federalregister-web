module SparklineHelper
  def document_frequency_sparklines(title, sparklines)
    render partial: 'components/sparklines', locals: {
        sparklines: sparklines,
        title: title,
      }
  end
end
