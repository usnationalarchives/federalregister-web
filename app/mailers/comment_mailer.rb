class CommentMailer < ActionMailer::Base
  include SendGrid
  layout "mailer/two_col_1_2"
  helper :mailer

  default :from => "My Federal Register <noreply@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def comment_copy(user, comment)
    @user = user
    @comment = CommentDecorator.decorate( comment )
    @utility_links = [['manage my subscriptions', subscriptions_url()]]
    @highlights = EmailHighlight.pick(2)
    @fr_comments_url = fr_comment_url_by_environment

    sendgrid_category "Comment Copy"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'comment copy email'

    mail(
      :to => user.email,
      :subject => "[FR] Your comment on #{@comment.article.title}"
    ) do |format|
      format.text { render('comment_copy') }
      format.html { Premailer.new( render('comment_copy'),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  def comment_posting_notification(user, comment)
    @user = user
    @comment = CommentDecorator.decorate( comment )
    @utility_links = [["view documents I've comment on", comments_url()]]
    @highlights = EmailHighlight.pick(2)
    @fr_comments_url = fr_comment_url_by_environment

    sendgrid_category "Comment Posting Notification"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'comment publication notification email'

    mail(
      :to => user.email,
      :subject => "[FR] Your comment on #{@comment.article.citation} has been publicly posted"
    ) do |format|
      format.text { render('comment_posting_notification') }
      format.html { Premailer.new( render('comment_posting_notification'),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  class Preview < MailView
    def comment_copy
      VCR.eject_cassette
      VCR.use_cassette("development") {
        user = User.new(:email => 'name@example.com',
                        :name  => 'Jill Smith',
                        :cofirmation => '123456789')
        comment = Comment.find(89)
        comment.secret = '6mge902mb11t6g'
        CommentMailer.comment_copy(user, comment)
      }
    end

    def comment_posting_notification
      VCR.eject_cassette
      VCR.use_cassette("development") {
        user = User.new(:email => 'name@example.com',
                        :name  => 'Jill Smith',
                        :cofirmation => '123456789')
        comment = Comment.find(89)
        comment.secret = '6mge902mb11t6g'
        CommentMailer.comment_posting_notification(user, comment)
      }
    end
  end

  private

  def fr_comment_url_by_environment
    if Rails.env.staging?
      "https://fr2.criticaljuncture.org/my/comments"
    elsif Rails.env.development?
      "www.fr2.local:8080/my/comments"
    else
      "https://www.federalregister.gov/my/comments"
    end
  end
end
