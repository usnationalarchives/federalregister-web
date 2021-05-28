class CommentPostingNotifier
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :web_reg_gov

  sidekiq_throttle({
    # Allow maximum 1 concurrent jobs of this class at a time.
    :concurrency => { :limit => 1 },
    :threshold => {
      limit:  Settings.regulations_dot_gov.throttle.at,
      period: Settings.regulations_dot_gov.throttle.per,
    }
  })

  def perform(comment_id)
    comment = Comment.find(comment_id)
    comment.checked_comment_publication_at = Time.current

    reg_dot_gov_comments = client.find_comments('filter[searchTerm]' => comment.comment_tracking_number)

    if reg_dot_gov_comments.size > 0
      comment.comment_document_number = reg_dot_gov_comments.first.regulations_dot_gov_document_id
      CommentMailer.comment_posting_notification(comment.user, comment).deliver_now
    end

    comment.save(:validate => false)
  end

  private

  def client
    RegulationsDotGov::V4::Client.new(
      api_key: Rails.application.secrets[:data_dot_gov][:comment_notifier_api_key]
    )
  end

end
