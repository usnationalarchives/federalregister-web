$(document).ready ->
  $('#metadata_content_area')
    .on 'click', '.comment_next_steps .my_fr a.notifications', (e)->
      e.preventDefault()
      e.stopPropagation()

      link = $(this)

      $.ajax({
        url: link.attr 'href'
        dataType: 'json'
        type: link.data 'method'
        data: {
          comment_tracking_number: link.data 'comment-tracking-number'
        }
        success: (response)->
          link
            .html response.link_text

          link
            .data 'method', response.method

          link
            .closest 'li'
            .find '.description'
              .html response.description

          link
            .toggleClass 'remove'

      })
