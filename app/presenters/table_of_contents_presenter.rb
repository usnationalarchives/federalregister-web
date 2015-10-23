class TableOfContentsPresenter
  class AgencyPresenter
    attr_reader :agency, :articles, :article_count
    delegate :id, :parent_id, :url, :to => :agency

    def initialize(toc_view, agency)
      @toc_view = toc_view
      @agency = agency
      @articles = []
    end

    def add_article(article)
      @articles << article
    end

    def name
      agency.name
    end

    def slug
      url.sub(/^.*\//,'')
    end

    def children
      @children ||= @toc_view.agencies.select{|a| a.parent_id == id}
    end

    def article_count
      @article_count ||= articles.size + children.sum(&:article_count)
    end
    
    def articles_by_type_and_toc_subject
      articles.group_by(&:type).sort_by{|type,articles| type}.reverse.map do |type, articles_by_type|
        articles_by_toc_subject = articles_by_type.group_by(&:toc_subject).map do |toc_subject, articles_by_toc_subject|
          [toc_subject, articles_by_toc_subject.sort_by{|e| [e.toc_doc.try(:downcase) || '', (e.toc_doc || e.title).downcase]}]
        end
        [type, articles_by_toc_subject]
      end
    end
  end

  class StubAgencyPresenter < AgencyPresenter
    def name
      agency.attributes["raw_name"]
    end

    def slug
      name.downcase.gsub(/\W+/,'-')
    end

    def children
      []
    end
  end

  attr_accessor :agencies, :agency_ids, :articles_with_agencies, :articles
  def initialize(articles, options = {})
    @articles = ArticleDecorator.decorate(articles)
    @articles_with_agencies =  @articles.sort_by{|e| [e.try_if_exists(:start_page) || 0, e.try_if_exists(:end_page) || 0, e.document_number]}

    agencies_hsh = {}
    @articles_with_agencies.each do |article|
      # create document views for all associated agencies, powering the 'See XXX'
      article.agencies.reject{|x| x.id.nil? }.each do |agency|
        agencies_hsh[agency.name] ||= AgencyPresenter.new(self, agency)
        if options[:always_include_parent_agencies] && agency.parent.present?
          agencies_hsh[agency.parent.name] ||= AgencyPresenter.new(self, agency.parent)
        end
      end

      if article.agencies.all?{|a| a.id.nil?}
        agency = StubAgencyPresenter.new(self, article.agencies.first)
        agencies_hsh[agency.name] ||= agency
        agencies_hsh[agency.name].add_article(article)
      end      

      parent_agency_ids = article.agencies.map(&:parent_id).compact
      article.agencies.reject{|a| parent_agency_ids.include?(a.id)}.each do |agency|
        next if agency.id.blank?
        agencies_hsh[agency.name].add_article(article)
      end
    end
    
    # generate list of agencies, downcasing to sort appropriately (eg 'Health and Human...' before 'Health Resources...')
    @agencies = agencies_hsh.values.sort_by{|a| a.name.downcase}
  end

  def article_count
    @article_count ||= @articles.size
  end
end
