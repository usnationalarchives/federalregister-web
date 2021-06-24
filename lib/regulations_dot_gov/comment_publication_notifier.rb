class RegulationsDotGov::CommentPublicationNotifier
  def perform
    comments.find_each do |comment|
      if confirmed_emails_by_user_id[comment.user_id]
        CommentPostingNotifier.perform_async(comment.id)
      end
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

  private

  def confirmed_emails_by_user_id
    Ofr::UserEmailResultSet.
      get_user_emails(comments.pluck(:user_id).uniq)
  end
  memoize :confirmed_emails_by_user_id

end
