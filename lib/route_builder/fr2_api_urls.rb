module RouteBuilder::Fr2ApiUrls
  extend RouteBuilder::Utils

  ### DOCUMENTS
  def document_api_path(document, options, params={})
    path = "documents/#{document.document_number}"

    # document api path doesn't support format currently
    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_path_for(path, params)
  end

  def document_api_url(document, options, params={})
    fr2_api_urlify(document_api_path(document, options, params))
  end

  def documents_api_path(documents, options, params={})
    document_numbers = documents.map{|d| d.document_numbers}.join(',')
    path = "documents/#{document_numbers}"

    # document api path doesn't support format currently
    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_path_for(path, params)
  end

  def documents_api_url(documents, options, params={})
    fr2_api_urlify(documents_api_path(documents, options, params))
  end

  def documents_search_api_path(params, options)
    path = "documents"

    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_path_for(path, params)
  end

  def documents_search_api_url(params, options)
    fr2_api_urlify(documents_search_api_path(params, options))
  end

  ### PUBLIC INSPECTION DOCUMENTS
  
  def public_inspection_document_api_path(document, options, params={})
    path = "public-inspection-documents/#{document.document_number}"

    # document api path doesn't support format currently
    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_path_for(path, params)
  end

  def public_inspection_document_api_url(document, options, params={})
    fr2_api_urlify(public_inspection_document_api_path(document, options, params))
  end

  def public_inspection_search_api_path(params, options)
    path = "public-inspection-documents"

    if options && options[:format]
      path += ".#{options[:format]}"
    end

    fr2_api_path_for(path, params)
  end

  def public_inspection_search_api_url(params, options)
    fr2_api_urlify(public_inspection_search_api_path(params, options))
  end

  private

  def fr2_api_path_for(end_point, params)
    arr = ["/api/v1/#{end_point}"]
    arr << params.to_param unless params.blank?

    arr.join('?')
  end

  def fr2_api_urlify(path)
    "#{Settings.federal_register.api_url}/#{path.sub('/api/v1/', '')}"
  end
end
