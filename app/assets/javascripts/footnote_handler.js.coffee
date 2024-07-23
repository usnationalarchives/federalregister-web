class @FR2.FootnoteHandler
  constructor: () ->
    this.interceptFootnoteClicks()
    this.interceptBackToCitationClicks()

  interceptFootnoteClicks: ->
    $('#fulltext_content_area').on 'click', 'a.footnote-reference', (event) ->
      event.preventDefault()
      href                  = $(this).attr('href')
      originalPageNumber    = href.split('-').at(-1).replace(/\D/g, '')
      alternatePossibleHref = href.replace("p#{originalPageNumber}", "p#{(parseInt(originalPageNumber, 10) + 1)}")

      if $(href).length > 0
        window.location.href = href
      else if $(alternatePossibleHref).length > 0
        window.location.href = alternatePossibleHref
      else
        console.log('Unable to locate the footnote on the page')

  interceptBackToCitationClicks: ->
    $('#fulltext_content_area').on 'click', 'a.back', (event) ->
      event.preventDefault()
      href                  = $(this).attr('href')
      originalPageNumber    = href.split('-').at(-1).replace(/\D/g, '')
      alternatePossibleHref = href.replace("p#{originalPageNumber}", "p#{(parseInt(originalPageNumber, 10) - 1)}")

      if $(href).length > 0
        window.location.href = href
      else if $(alternatePossibleHref).length > 0
        window.location.href = alternatePossibleHref
      else
        console.log('Unable to locate the original citation on the page')
