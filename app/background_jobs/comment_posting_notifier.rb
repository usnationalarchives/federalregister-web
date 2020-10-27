class CommentPostingNotifier
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reg_gov
  sidekiq_throttle_as :reg_gov_api

  def perform(comment_id)
    comment = Comment.find(comment_id)
    comment.checked_comment_publication_at = Time.current

    documents = client.find_documents(:s => comment.comment_tracking_number, :dct => "PS")

    if documents.size > 0
      comment.comment_document_number = documents.first.document_id
      CommentMailer.comment_posting_notification(comment.user, comment).deliver_now
    end

    comment.save(:validate => false)
  end

  private

  def client
    RegulationsDotGov::Client.new
  end

end
