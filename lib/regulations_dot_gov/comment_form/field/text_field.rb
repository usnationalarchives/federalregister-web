class RegulationsDotGov::CommentForm::Field::TextField < RegulationsDotGov::CommentForm::Field
  def max_length
    attributes["@maxLength"].try(:to_i)
  end
end
