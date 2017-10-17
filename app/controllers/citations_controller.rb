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
    document_numbers = search.search_details.suggestions.
      select{|s| s.respond_to?(:document_numbers)}.
      map(&:document_numbers).
      flatten

    case document_numbers.size
    when 0
      # none found
      @error = 'No documents found with citation'
    when 1
      @citation = FrArchivesCitation.new(@volume, @page)
      if @citation.after_archives?
        redirect_to short_document_path(document_numbers.first)
      elsif @citation.pdf_url
      elsif @citation.before_archives?
        @error = "Older volumes may be available through a <a href='https://catalog.gpo.gov/fdlpdir/public.jsp' class='external'> Federal Depository Library</a>.".html_safe
      else
        @error = 'No documents found with citation'
      end
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
      flatten

    if document_numbers.size == 0
      render
    else
      redirect_to short_document_path(document_numbers.first)
    end
  end
end
