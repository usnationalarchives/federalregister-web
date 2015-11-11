module RouteBuilder::Fr2ApiUrls
  extend RouteBuilder::Utils

  ### DOCUMENTS
  add_static_route :api_documents_csv_url do |api_params|
    fr2_api_url_for('documents.csv', api_params)
  end

  add_static_route :api_documents_json_url do |api_params|
    fr2_api_url_for('documents.json', api_params)
  end

  add_static_route :api_documents_search_details_url do |api_params|
    fr2_document_api_url_for('search-details', api_params)
  end

  add_static_route :api_documents_facet_url do |facet, api_params|
    fr2_document_api_url_for("facets/#{facet}", api_params)
  end

  ### PUBLIC INSPECTION DOCUMENTS
  add_static_route :api_pi_documents_facet_url do |facet, api_params|
    fr2_pi_document_api_url_for("facets/#{facet}", api_params)
  end

  private

  def fr2_document_api_url_for(end_point, params)
    fr2_api_url_for("documents/#{end_point}", params)
  end

  def fr2_pi_document_api_url_for(end_point, params)
    fr2_api_url_for("public_inspection/#{end_point}", params)
  end

  def fr2_api_url_for(end_point, params)
    "#{Settings.federalregister.api_url}/#{end_point}?#{params}"
  end
end
