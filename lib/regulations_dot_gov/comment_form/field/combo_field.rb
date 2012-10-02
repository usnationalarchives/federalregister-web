class RegulationsDotGov::CommentForm::Field::ComboField < RegulationsDotGov::CommentForm::Field
	MAPPING = {
    'us_state'   => {:dependent_on => 'country',         :values => ['United States', 'Canada']},
		'gov_agency' => {:dependent_on => 'gov_agency_type', :values => ['Federal']}
	}

	def dependent_on
		mapping[:dependent_on]
	end

	def dependencies
		dependencies = {}
		mapping[:values].each do |val|
			dependencies[val] = client.get_options("#{name}_v", 'value' => val, 'field' => dependent_on).map do |option|
				[option.value, option.label]
			end
		end

		dependencies
	end

	def mapping
		MAPPING[name] or raise "Combo field #{name} unrecognized; need to be configured."
	end
end
