$(document).ready ->
  missingDocumentImageUrlBase = "https://s3.amazonaws.com/images.#{window.location.hostname.replace('www.', '')}/missingimage"

  $('#fulltext_content_area').on 'error', 'img.document-graphic-image', ->
    link = $(this)

    link
      .attr 'original-src', link.attr('src')

    link
      .attr 'src', "#{missingDocumentImageUrlBase}/large.png"

    link
      .closest 'a.document-graphic-link'
      .attr 'href', "#{missingDocumentImageUrlBase}/original.png"
