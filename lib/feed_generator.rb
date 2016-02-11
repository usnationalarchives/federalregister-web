class FeedGenerator
  include ActionView::Helpers::TagHelper

  def initialize(feed_url, title, args)
    @args = args
    @feed_url = feed_url
    @search_conditions = args.fetch(:search_conditions)
    @title = title
  end

  def to_html
    build_base_options
    add_document_search
    add_pi_search
    add_default_subscription

    tag(:link, @link_html_options)
  end

  private

  def build_base_options
    @link_html_options = {
      rel: 'alternate',
      type: 'application/rss+xml',
      title: @title,
      href: @feed_url,
      class: 'subscription_feed'
    }
  end

  def add_document_search
    document_search_conditions = document_search.valid_search? ? @search_conditions.to_json : nil
    @link_html_options[:'data-document-search-conditions'] = document_search_conditions
  end

  def add_pi_search
    pi_search_conditions = pi_search.valid_search? ? @search_conditions.to_json : nil
    @link_html_options[:'data-public-inspection-search-conditions'] = pi_search_conditions
  end

  def add_default_subscription
    if @args[:subscription_default]
      @link_html_options[:'data-default-search-type'] = @args.fetch(:subscription_default)
    end
  end

  def document_search
    @document_search ||= Search::Document.new(conditions: @search_conditions)
  end

  def pi_search
    @pi_search ||= Search::PublicInspection.new(conditions: @search_conditions)
  end
end
