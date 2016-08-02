#= require old/application

#= require utilities/csrf_setup
#= require namespace

#= require handlebars_helpers
#= require storage.js
#= require analytics.js

# Namespaced JS Classes
#= require utilities/analytics
#= require utilities/cj_tooltip
#= require utilities/modal
#= require utilities/toggle
#= require utilities/list_item_filter
#= require utilities/list_item_sorter
#= require utilities/non_persistent_storage
#= require utilities/user_utils

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
#= require subscription_filters
#= require tipsy
#= require document_page
#= require public_inspection
#= require utility_bar
#= require documents/utility_bar/document_tools
#= require documents/missing_image

# Homepage
#= require home/home_section_preview_manager

#= require old/navigation

#= require_tree ./documents
#= require fr_index_popover_handler
#= require fr_index
#= require issues

#= require search

# Instantiate and bind common application js items
#= require app
