$(document).ready ->
  if $('a#start_comment[data-comment=1]').length > 0
    FR2.commentFormHandlerInstance = new FR2.CommentFormHandler(
      $('#flash_message.comment')
    )
