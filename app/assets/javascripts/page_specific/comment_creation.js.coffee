$(document).ready ->
  commentLink = $('a#start_comment[data-comment=1]').get(0)
  republishedDocumentCommentUrl = $('#comment-bar').data('republished-document-comment-url')

  if (commentLink || window.location.hash == "#open-comment") && window.location.hash != '#addresses'
    FR2.commentFormHandlerInstance = new FR2.CommentFormHandler(
      $('#comment-bar.comment')
    )
  else if republishedDocumentCommentUrl
    new FR2.CommentingUnavailableHandler(
      $('#comment-bar.comment'),
      "<p>Submitting a formal comment directly via federalregister.gov may be available for the original document.  Click the button below to view the original document.</p></br><a href='#{republishedDocumentCommentUrl}' class='fr_button medium primary'>View Original Document</a>",
      false
    )
  else
    new FR2.CommentingUnavailableHandler(
      $('#comment-bar.comment'),
      "<p>Submitting a formal comment directly via federalregister.gov is not available for this document at this time.  However, you can click the button below to view more information on alternate methods of comment submission.</p></br><a class='fr_button medium primary jqm-close-js'>View Additional Information</a>"
    )
