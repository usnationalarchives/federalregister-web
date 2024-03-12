#= require utilities/csrf_setup
#= require namespace

#= require handlebars_helpers

# Namespaced JS Classes
#= require utilities/analytics
#= require utilities/cj_tooltip
#= require utilities/honeybadger_configurer
#= require utilities/modal
#= require utilities/toggle
#= require utilities/list_item_filter
#= require utilities/list_item_sorter
#= require utilities/non_persistent_storage
#= require utilities/user_data
#= require utilities/user_navigation_manager
#= require utilities/user_utils

#= require ofr/copy_to_clipboard
#= require ofr/site_feedback_handler
#= require ofr/zendesk_form_handler
#= require ofr/zendesk_modal_handler

#= require components
#= require fr_modal
#= require form_utils
#= require subscription
#= require user_preference_store
#= require user_session

#= require_tree ./components/comments/

#= require_self

#= require utilities/tooltip
#= require folder_actions
#= require tipsy
#= require document_page
#= require public_inspection
#= require utility_nav

# Homepage
#= require home/home_section_preview_manager

#= require_tree ./documents
#= require content_copy_to_clipboard
#= require fr_index_popover_handler
#= require footnote_handler
#= require interstitial_modal_handler
#= require table_fixed_header_handler
#= require table_fixed_header_manager
#= require table_modal_handler
#= require fr_index
#= require issues
#= require navigation
#= require search

# Instantiate and bind common application js items
#= require app
