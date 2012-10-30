class CommentDecorator < ApplicationDecorator
  decorates :comment

  delegate :agency_participates_on_regulations_dot_gov?,
    :to => :comment_form

  def human_error_messages
    if errors.present?
      "There #{errors.count > 1 ? 'were' : 'was'} #{h.pluralize(errors.count, 'problem')} with your submission. 
       Please fix them below and submit your comment again."
    end
  end

  def article
    @article ||= ArticleDecorator.decorate( FederalRegister::Article.find(model.document_number) )
  end

  def agency_name
    'the ' + comment_form.agency_name
  end

  def commented_at
    if comment.created_at
      comment.created_at.to_formatted_s(:date)
    end
  end
end
