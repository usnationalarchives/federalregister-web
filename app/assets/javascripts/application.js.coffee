#= require old/application

#= require utilities/csrf_setup
#= require namespace

#= require handlebars_helpers
#= require storage.js
#= require analytics.js
#= require tender_widget_custom.js

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

#= require components
#= require fr_modal
#= require form_utils
#= require subscription
#= require user_session

#= require_tree ./components/comments/

#= require_self

#= require utilities/tooltip
#= require folder_actions
#= require add_to_folder
#= require tipsy
#= require document_page
#= require public_inspection
#= require utility_bar
#= require documents/utility_bar/document_tools
#= require documents/missing_image
#= require documents/paragraph_citation

# Homepage
#= require home/home_section_preview_manager

#= require old/navigation

#= require_tree ./documents
#= require content_copy_to_clipboard
#= require fr_index_popover_handler
#= require footnote_handler
#= require table_fixed_header_handler
#= require table_fixed_header_manager
#= require table_modal_handler
#= require fr_index
#= require issues

#= require search
#= require zendesk_form_handler

# Instantiate and bind common application js items
#= require app
