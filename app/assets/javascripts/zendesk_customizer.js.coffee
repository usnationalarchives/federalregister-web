class @FR2.ZendeskCustomizer

  constructor: ->
    # Pre-populate custom context field
    window.zESettings = {
      webWidget: {
        contactForm: {
          fields: [
            { id: 360053300454, prefill: { '*': this.browserMetadata() } }
          ]
        }
      }
    }

    # Manipulate iframe to hide custom field.  It's necessary to append a stylesheet to the Zendesk web widget iframe in order for the CSS to be applied as expected.  Manipulating the field visibility when doing so using standard JS and/or CSS does not work due to cross-domain concerns.
    zE 'webWidget:on', 'open', () ->
      setTimeout (->
        iframe = document.querySelector('#webWidget')
        style = document.createElement('style')
        style.textContent = "
          [data-fieldid='key:360053300454'] {
            display: none;
          }
          [name='key:360053300454'] {
            display: none;
          }
        "
        iframe.contentDocument.head.appendChild style
      ), 1

  browserMetadata: ->
    metadata = _.pick(bowser, 'name', 'version','osname', 'osversion', 'blink')
    metadata.project = 'FR'
    JSON.stringify(metadata)
