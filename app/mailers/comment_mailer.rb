class CommentMailer < ActionMailer::Base
  include SendGrid
  layout "mailer/two_col_1_2"
  helper :mailer

  default :from => "My Federal Register <noreply@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  class NoConfirmedEmail < StandardError; end

  def comment_posting_notification(user, comment)
    @user = user
    @comment = CommentDecorator.decorate( comment )
    @utility_links = [["view documents I've comment on", comments_url()]]
    @highlights = EmailHighlight.pick(2)
    @fr_comments_url = "#{Settings.services.fr.web.base_url}/my/comments"

    sendgrid_category "Comment Posting Notification"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'comment publication notification email'

    mail(
      :to => user.email,
      :subject => "[FR] Your comment on #{@comment.document.citation} has been publicly posted"
    ) do |format|
      format.text { render('comment_posting_notification') }
      format.html { render('comment_posting_notification') }
    end
  end

  class Preview < MailView
    def comment_copy_participating_agency
      VCR.eject_cassette
      VCR.use_cassette("development") {
        user = User.new(:email => 'name@example.com',
                        :name  => 'Jill Smith',
                        :confirmation => '123456789')
        comment = FactoryGirl.build(:comment, created_at: Time.current)

        CommentMailer.comment_copy(user, comment)
      }
    end

    def comment_copy_non_participating_agency
      VCR.eject_cassette
      VCR.use_cassette("development") {
        user = User.new(:email => 'name@example.com',
                        :name  => 'Jill Smith',
                        :confirmation => '123456789')
        comment = FactoryGirl.build(:comment, :non_participating_agency, created_at: Time.current)

        CommentMailer.comment_copy(user, comment)
      }
    end

    def comment_posting_notification
      VCR.eject_cassette
      VCR.use_cassette("development") {
        user = User.new(:email => 'name@example.com',
                        :name  => 'Jill Smith',
                        :confirmation => '123456789')
        comment = FactoryGirl.build(:comment, :publicly_posted)
        CommentMailer.comment_posting_notification(user, comment)
      }
    end
  end
end
