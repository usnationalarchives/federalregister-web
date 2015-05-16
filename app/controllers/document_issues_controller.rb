class DocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: [:by_month, :navigation]

  def test_page
  end

  def show
    cache_for 1.day
    parsed_date = parse_date_from_params

    if DocumentIssue.published_on(parsed_date).has_documents?
      @presenter = TableOfContentsPresenter.new(parsed_date)
      @doc_presenter = DocumentIssuePresenter.new(parsed_date)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def by_month
    cache_for 1.day

    begin
      @date = Date.parse("#{params[:year]}-#{params[:month]}-01")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end

    @document_dates = FederalRegister::Facet::Document::Daily.search(
      {:conditions =>
        {:publication_date =>
          {:gte => @date.beginning_of_month,
           :lte => @date.end_of_month
          }
        }
      }
    ).select{|result|result.count > 0}.map{|result|result.slug.to_date  }

    @table_class = params[:table_class]
  end

  def navigation
    cache_for 1.day
    @doc_presenter = DocumentIssuePresenter.new(
      DocumentIssue.current.publication_date
    )
  end
end
