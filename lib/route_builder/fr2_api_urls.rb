module RouteBuilder::Fr2ApiUrls
  extend RouteBuilder::Utils

  ### DOCUMENTS
  def document_api_url(document, options, params={})
    path = "documents/#{document.document_number}"

    # document api path doesn't support format currently
    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_url_for(path, params)
  end

  def documents_api_url(documents, options, params={})
    document_numbers = documents.map{|d| d.document_numbers}.join(',')
    path = "documents/#{document_numbers}"

    # document api path doesn't support format currently
    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_url_for(path, params)
  end

  def documents_search_api_url(params, options)
    path = "documents"

    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_url_for(path, params)
  end

  ### PUBLIC INSPECTION DOCUMENTS
  def public_inspection_search_api_url(params, options)
    path = "public-inspection-documents"

    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_url_for(path, params)
  end

  private

  def fr2_api_url_for(end_point, params)
    arr = ["#{Settings.federal_register.api_url}/#{end_point}"]
    arr << params.to_param unless params.blank?

    arr.join('?')
  end
end
