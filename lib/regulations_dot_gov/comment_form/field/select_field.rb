class RegulationsDotGov::CommentForm::Field::SelectField < RegulationsDotGov::CommentForm::Field
  def option_values
    parameters = {}
    if name == 'comment_category'
      parameters['dependentOnValue'] = agency_id
    end

    @options ||= client.get_option_elements(name, parameters)
  end

  def default
    options.first(&:default?)
  end
end
