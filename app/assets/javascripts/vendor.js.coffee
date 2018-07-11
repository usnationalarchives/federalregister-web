#= require jquery-3.3.1.js
#= require jquery-ui-1.12.1.custom.min.js
#= require jquery_ujs
#= require modernizr.custom.js
#= require underscore
#= require strftime
#= require handlebars-1.0.0.rc.3
#= require bootstrap/dropdown
#= require bootstrap/tab
#= require jquery.clippy.min
#= require js.cookie
#= require jquery.lazy.min

# RANDOM ASSORTMENT UTILITIES
#= require jquery.utilities

#= require jqModal

# COMMENT FORMS
#= require blueimpFileupload
#= require amplify.store-1.1.0.min.js
#= require jquery.scrollintoview.min.js

# EMAIL ADDRESS VALIDATOR/HELPER
#= require mailcheck.min.js

#= require jquery.tipsy.js

# PLACEHOLDER SUPPORT FRO IE 8-9
#= require jquery.textPlaceholder

# BETTER SELECT MULTIPLE PLUGIN
#= require jquery.bsmselect

# CAROUSEL
#= require iscroll

# SEARCH
# debounce search result count lookahead
#= require jquery.typewatch.js
# format numbers appropriately with comma's, etc
#= require numeral.min.js
#= require languages.min.js

# STICKY FROM SEMANTIC-UI (doc utility bar)
#= require semantic-ui/sticky.min.js

# PREVENT TAB NABBING BY changing window.open behavior and
# passing all target blank to blankshield
#= require blankshield.min.js
$(document).ready ()->
  blankshield.patch()
  blankshield($('a[target=_blank], a[target=blank]').not('#start_comment'))
