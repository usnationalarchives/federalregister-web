class RegulationsDotGov::CommentFormCacheWarmer
  def perform
    start_time = Time.now

    client = RegulationsDotGov::Client.new(:read_from_cache => false)

    options_to_load = Set.new
    documents.each do |document|
      comment_form = client.get_comment_form(document.document_number)

      options_to_load += comment_form.
        fields.
        select{|field| field.is_a?(RegulationsDotGov::CommentForm::Field::SelectField)}.
        map{|option| [option.name, option.option_parameters]}
    end

    options_to_load.each do |field_name, options|
      client.get_option_elements(field_name, options)
    end

    RegulationsDotGov::CommentForm::Field::ComboField::MAPPING.each do |field_name, values|
      values.each do |value|
        client.get_option_elements(field_name, 'dependentOnValue' => value)
      end
    end

    end_time = Time.now

    puts "Regulations.gov cache warm complete. {'start_time': #{start_time}, 'end_time': #{end_time}, 'duration': #{end_time - start_time}}"
  end

  def documents
    start_date = Date.current

    # load documents open for comment published in last 4 months
    (0..3).map do |i|
      FederalRegister::Article.search(
        :conditions => {
          :publication_date => {
            :lte => start_date.advance(:months => -1 * i).to_s(:iso),
            :gte => start_date.advance(:months => -1 * (i+1)).to_s(:iso),
          },
          :accepting_comments_on_regulations_dot_gov => 1
        },
        :per_page => 1000,
        :fields => [:document_number]
      )
    end.map(&:results).flatten
  end
end
