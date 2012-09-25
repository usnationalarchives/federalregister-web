module CommentsHelper
  def comment_input_field_options(field)
    options = {
      :label    => field.label,
      # :hint     => field.hint,
      :required => field.required?,
    }

    if field.publically_viewable?
      options[:wrapper_html] = {:class => "public"}
    end

    case field
    when RegulationsDotGov::CommentForm::Field::TextField
      if field.max_length > 0
        options.merge!(
          :as => :string,
          :size => field.max_length
        )
      else
        options[:as] = :text
      end
    when RegulationsDotGov::CommentForm::Field::SelectField
      options.merge!(
        :as => :select,
        :collection => field.options,
        :member_value => :value,
        :member_label => :label
      )
    when RegulationsDotGov::CommentForm::Field::ComboField
    end

    options
  end
end
