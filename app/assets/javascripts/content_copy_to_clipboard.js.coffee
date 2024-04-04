class @FR2.ContentCopyToClipboard
  constructor: (content)->
    @content = $(content)
    @addEvents()

  addEvents: ->
    $(document).on 'copy', (e) ->
      selection = document.getSelection()

      # limit modifications to selections that include content
      return unless $(selection.anchorNode).parents('.doc').length || $(selection.focusNode).parents('.doc').length
      fragment = selection.getRangeAt(0).cloneContents()
      div = document.createElement('div')
      div.contentEditable = true
      div.readOnly = false
      div.appendChild(fragment.cloneNode(true))
      $(div).attr('id','copy_from')

      # set explicit indents for Word
      for i in [1...8] by 1
        $(div).find('.indent-' + i).css('margin-left', (i * 12)+ 'px')

      # convert relative => absolute (href prop returns absolute, setting the existing value is sufficient)
      $(div).find("a[href^='/']").prop( "href", (_i, href)->
        return href
      )

      $(div).find(":header, .inline-header, .paragraph-heading, dt").css('font-weight', 'bold')
      $(div).find(".expand-table-link, .paragraph-citation, #feedbackbutton, #launcher, .no-print-header, .content-nav-wrapper, .unprinted-element, .document-clipping-actions, .regulations-dot-gov-logo").remove()

      html = div.innerHTML

      # copy html version (first added, default)
      e.originalEvent.clipboardData.setData('text/html', html)

      # copy text/plain version (fallback for apps w/out text/html support)
      doc = new DOMParser().parseFromString(html, 'text/html')
      text = doc.body.textContent
      text = text.replace(/^ +/gm, '')
      text = text.replace(/\n+/gm, '\n\n')

      e.originalEvent.clipboardData.setData('text/plain', text)

      e.preventDefault()

  replaceTag: (elements, new_tag) ->
    sources = $(elements).get()
    for i in [0...sources.length] by 1
      source = sources[i]
      target = $(document.createElement(new_tag))
      target.html($(source).html())
      source_attributes = source.attributes
      target_attributes = new Object()
      for j in [0...source_attributes.length] by 1
        attribute = source_attributes[j]
        target_attributes[attribute.nodeName] = attribute.nodeValue

      target.attr(target_attributes)
      $(source).replaceWith(target)
