class CitationsController < ApplicationController
  skip_before_action :authenticate_user!

  CFR_REGEXP = /(\d+)-CFR-(\d+)(?:\.(\d+))?/

  def cfr
    title, part, section = params[:citation].match(CFR_REGEXP)[1..3]

    cfr_reference = "#{title} CFR #{part}#{".#{section}" if section.present?}"
    redirect_to "https://www.ecfr.gov/cfr-reference?#{{cfr: {reference: cfr_reference}}.to_query}"
  end

  def fr
    @volume, @page = params[:volume], params[:page]
    @fr_archives_citation = FrArchivesCitation.new(@volume, @page)

    search = SearchPresenter::Document.new(conditions: {term: "#{@volume} FR #{@page}"}).search
    document_numbers = search.search_details.suggestions.
      select{|s| s.respond_to?(:document_numbers)}.
      map(&:document_numbers).
      flatten

    case document_numbers.size
        when 0
      # none found
    when 1
      redirect_to short_document_path(document_numbers.first)
    else
      @documents = DocumentDecorator.decorate_collection Document.find_all(document_numbers)
    end
  end

  def eo
    @eo_number = params[:eo_number]

    search = SearchPresenter::Document.new(conditions: {term: "EO #{@eo_number}"}).search
    document_numbers = search.search_details.suggestions.
      select{|s| s.respond_to?(:document_numbers)}.
      map(&:document_numbers).
      flatten.
      compact

    if document_numbers.size == 0
      render
    else
      redirect_to short_document_path(document_numbers.first)
    end
  end
end
