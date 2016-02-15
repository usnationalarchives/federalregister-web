class CitationsController < ApplicationController
  skip_before_filter :authenticate_user!

  CFR_REGEXP = /(\d+)-CFR-(\d+)(?:\.(\d+))?/

  def cfr
    title, part, section = params[:citation].match(CFR_REGEXP)[1..3]
    redirect_to fdsys_cfr_url(title, part, section)
  end

  def fr
    @volume, @page = params[:volume], params[:page]

    search = SearchPresenter::Document.new(conditions: {term: "#{@volume} FR #{@page}"}).search
    document_numbers = search.search_details.suggestions.map(&:document_numbers).flatten

    case document_numbers.size
    when 0
      # none found
    when 1
      redirect_to short_document_path(document_numbers.first)
    else
      @documents = DocumentDecorator.decorate_collection Document.find_all(document_numbers)
    end
  end
end
