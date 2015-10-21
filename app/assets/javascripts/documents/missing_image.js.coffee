$(document).ready ->
  missingDocumentImageUrlBase = "https://s3.amazonaws.com/images.#{window.location.hostname.replace('www.', '')}/missingimage"

  $('#fulltext_content_area').on 'error', 'img.entry_graphic', ->
    link = $(this)

    link
      .attr 'original-src', link.attr('src')

    link
      .attr 'src', "#{missingDocumentImageUrlBase}/large.png"

    link
      .closest 'a.entry_graphic_link'
      .attr 'href', "#{missingDocumentImageUrlBase}/original.png"
