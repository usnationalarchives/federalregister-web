$(document).ready ->
  commentLink = $('a#start_comment[data-comment=1]').get(0)

  if (commentLink || window.location.hash == "#open-comment") && window.location.hash != '#addresses'
    FR2.commentFormHandlerInstance = new FR2.CommentFormHandler(
      $('#comment-bar.comment')
    )
  else
    new FR2.CommentingUnavailableHandler( $('#comment-bar.comment') )
