class RegulationsDotGov::CommentForm::Field::SelectField < RegulationsDotGov::CommentForm::Field
  def options
    @options ||= client.get_options(picklist_name)
  end 

  def default
    options.first(&:default?)
  end

  def picklist_name
    uri = URI.parse(attributes["uiControlTypeUrl"])
    query_params = CGI::parse(uri.query)
    query_params['lookup'].first
  end
end

