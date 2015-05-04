#= require vendor
#= require old/application

#= require utilities/ajax_setup
#= require app

#= require handlebars_helpers
#= require storage.js
#= require analytics.js
#= require analytics/comments

#= require components
#= require fr_modal
#= require form_utils
#= require subscription
#= require user_session

#= require_tree ./components/comments/
#= require page_specific/comment_creation
#= require page_specific/comment_notifications

#= require_self

#= require utilities/tooltip
#= require add_to_folder
#= require clippings
#= require clipping_filters
#= require subscription_filters
#= require tipsy
#= require article_page
#= require document_page
#= require public_inspection
#= require utility_bar
#= require home_carousel
#= require old/agency_list
#= require old/search
#= require old/rss
#= require_tree ./documents

# Namespaced JS Classes
#= require utilities/cj_tooltip

$(document).ready ()->
  $('.clippy').clippy({
    keep_text: true,
    clippy_path: '/assets/clippy.swf'
  })

  CJ.Tooltip.addFancyTooltip(
    '.cj-tooltip',
    {gravity: 's'},
    {position: 'centerTop'}
  )
