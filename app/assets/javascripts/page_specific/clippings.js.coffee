$(document).ready ->
  new FR2.ClippingsManager('#clipping-actions')

  # set the size of the clipping data div to match the size of the
  # document data div (which we assume is larger) so that we get our
  # nice dashed border seperating the two
  _.each $('ul#clippings li div.clipping_data'), (el)->
    $(el).height(
      $(el).siblings('div.document_data').height()
    )

  # also set the size of the add to folder pane and position checkbox
  # delay 200ms to allow for final page paint with webfonts (and thus element size)
  setTimeout(
    ()->
      _.each $('ul#clippings li div.add_to_folder_pane'), (el)->
        $(el).height(
          $(el).closest('ul#clippings li').innerHeight()
        )

        inputEl = $(el).find('input').last()
        inputEl.css(
          'margin-top',
          ($(el).height() / 2) - (inputEl.height() / 2)
        )
    200
  )
