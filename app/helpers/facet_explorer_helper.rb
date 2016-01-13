module FacetExplorerHelper
  def facet_explorer(args={})
    content_tag :div, class: 'bootstrap-scope' do
      content_tag :div, class: 'facet-explorer' do
        facet_explorer_header( args.fetch(:header) ) +
        facet_explorer_search( args.fetch(:search) ) +
        facet_explorer_table( args.fetch(:table) )
      end
    end
  end

  def facet_explorer_header(args)
    render partial: 'facets/explorer/header',
      locals: {
        icon: args.fetch(:icon),
        title: args.fetch(:title),
      }
  end

  def facet_explorer_search(args)
    render partial: 'facets/explorer/search',
      locals: {
        url: args.fetch(:url),
        placeholder: args.fetch(:placeholder),
        autocompleter_endpoint: args.fetch(:endpoint),
      }
  end

  def facet_explorer_table(args)
    render partial: 'facets/explorer/table',
      locals: {
        items: args.fetch(:items),
        header_count_width: args.fetch(:header_count_width),
        utm_source: args.fetch(:utm_source),
        utm_medium: args.fetch(:utm_medium),
        utm_content_type: args.fetch(:utm_content_type),
      }
  end
end
