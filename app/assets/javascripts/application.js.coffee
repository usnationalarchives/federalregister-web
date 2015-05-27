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
#= require folder_actions
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
#= require scrollMonitor
#= require_tree ./documents

# Namespaced JS Classes
#= require utilities/cj_tooltip
#= require utilities/modal
#= require utilities/element_scroller

$(document).ready ()->
  $('.clippy').clippy({
    keep_text: true,
    clippy_path: '/assets/clippy.swf'
  })

  CJ.Tooltip.addTooltip(
    '.cj-tooltip',
    {
      offset: 5
      opacity: 0.9
      delay: 0.3
      fade: true
    }
  )
