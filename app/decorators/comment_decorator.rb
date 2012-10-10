class CommentDecorator < ApplicationDecorator
  decorates :comment

  def human_error_messages
    if errors.present?
      "There #{errors.count > 1 ? 'were' : 'was'} #{h.pluralize(errors.count, 'problem')} with your submission. 
       Please fix them below and submit your comment again."
    end
  end
end
