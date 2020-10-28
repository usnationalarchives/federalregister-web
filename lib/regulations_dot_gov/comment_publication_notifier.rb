class RegulationsDotGov::CommentPublicationNotifier
  def perform
    comments.find_each do |comment|
      CommentPostingNotifier.perform_async(comment.id)
    end
  end

  def comments
    Comment.
      where("comments.user_id IS NOT NULL").
      where(:comment_publication_notification => true).
      where(:created_at => Time.current - 2.months .. Time.current).
      where(:comment_document_number => nil).
      where(:agency_participating => true)
  end

end
