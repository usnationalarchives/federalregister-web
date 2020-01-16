# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.federalregister.gov"

SitemapGenerator::Sitemap.create do

  sitemap_presenter = SitemapPresenter.new
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # SEARCHES
  add documents_search_path, :priority => 1
  add public_inspection_search_path, :priority => 0.75

  # SECTIONS
  Section.all.each do |section|
    add section_path(section), :priority => 0.75, :changefreq => 'daily'
  end

  # SUGGESTED SEARCHES
  SuggestedSearch.slugs.each do |slug|
    add suggested_search_path(slug), :priority => 0.75, :changefreq => 'daily'
  end

  # DOCUMENTS
  sitemap_presenter.documents do |document|
    # publication_date = document.publication_date
    add document.html_url, :changefreq => 'monthly'#, :lastmod => document.updated_at
  end

  # DOCUMENT ISSUES
  sitemap_presenter.document_issues.each do |document_issue|
    date = document_issue.publication_date
    add document_issue_path(
      date.year,
      date.month,
      date.day
    ), :priority => 0.75
  end

  add current_document_issue_path, :priority => 1.0, :changefreq => 'daily'

  # PUBLIC INSPECTION ISSUES
  sitemap_presenter.public_inspection_document_issues.each do |public_inspection_document_issue|
    date = public_inspection_document_issue.publication_date
    add public_inspection_issue_path(
      date.year,
      date.month,
      date.day
    ), :priority => 0.75
  end

  add public_inspection_path, :priority => 1.0, :changefreq => 'hourly'

  sitemap_presenter.public_inspection_documents.each do |document|
    add short_document_path(document.document_number)
  end

  #TOPICS
  add topics_path
  sitemap_presenter.topics.each { |topic| add topic_path(topic.slug) }

  # AGENCIES
  add agencies_path
  Agency.all.each do |agency|
    sitemap.add agency_path(agency.id), :priority => 0.75, :changefreq => 'daily'
  end

  # PRESIDENTIAL DOCUMENTS
  add all_presidential_documents_path
  ['other-presidential-documents', 'executive-orders', 'proclamations'].each do |presidential_document_type|
    add presidential_documents_path(presidential_document_type)
  end

  sitemap_presenter.executive_orders.each do |eo|
    add executive_order_path(eo.executive_order_number)
  end

end
