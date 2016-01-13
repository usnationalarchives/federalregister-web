module SearchResultHelper
  def embedded_search_results(result_object, options={})
    row_classes = options.fetch(:row_classes) { bootstrap_col(xs: 12, md: 12) }
    document_type = options.fetch(:document_type) { :official }

    embedded_search_results_header(result_object, row_classes, 'top', document_type) +
      embedded_search_results_documents(result_object.documents, row_classes, document_type) +
      embedded_search_results_header(result_object, row_classes, 'bottom', document_type)
  end

  def embedded_search_results_with_stacked_header(result_object, stacked_title, title, options={})
    row_classes = options.fetch(:row_classes) { bootstrap_col(xs: 12, md: 12) }
    document_type = options.fetch(:document_type) { :official }
    include_footer = options.fetch(:footer, true)

    output = stacked_embedded_search_results_header(result_object, row_classes, document_type, stacked_title, title) +
      embedded_search_results_documents(result_object.documents, row_classes, document_type)

    if include_footer
      output = output +
        embedded_search_results_header(result_object, row_classes, 'bottom', document_type)
    end

    output  
  end

  def embedded_search_results_header(result_object, row_classes, placement, document_type)
    content_tag :div, class: 'row' do
      content_tag :div, class: row_classes do
        render partial: 'search/results_header',
          locals: {
            per_page: result_object.per_page,
            placement: placement,
            result_count: result_object.documents.count,
            search_conditions: result_object.search_conditions,
            section: false,
            total_documents: result_object.total_document_count,
            type: document_type
          }
      end
    end
  end

  def embedded_search_results_documents(documents, row_classes, document_type)
    content_tag :div, class: 'row' do
      content_tag :div, class: row_classes do
        render partial: 'search/results',
          locals: {
            type: document_type,
            documents: documents,
            search: nil
          }
      end
    end
  end

  def stacked_embedded_search_results_header(result_object, row_classes, document_type, stacked_title, title)
    content_tag :div, class: 'row' do
      content_tag :div, class: row_classes do
        content_tag :div, class: "stacked-embedded-search-result-header" do
          content_tag(
            :h1,
            "<span class='small-stack'>#{stacked_title}</span>#{title}".html_safe
          ) +

          render(partial: 'search/results_header',
            locals: {
              per_page: result_object.per_page,
              placement: 'top',
              result_count: result_object.documents.count,
              search_conditions: result_object.search_conditions,
              section: false,
              total_documents: result_object.total_document_count,
              type: document_type
            })
        end
      end
    end
  end
end
