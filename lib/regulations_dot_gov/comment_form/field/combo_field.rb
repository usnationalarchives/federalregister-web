class RegulationsDotGov::CommentForm::Field::ComboField < RegulationsDotGov::CommentForm::Field
	MAPPING = {
    'us_state'   => {:dependent_on => 'country',         :values => ['United States', 'Canada']},
		'gov_agency' => {:dependent_on => 'gov_agency_type', :values => ['Federal']}
	}

	def dependent_on
		mapping[:dependent_on]
	end

	def dependent_values
		mapping[:values]
	end

	def dependencies
		dependencies = {}
		dependent_values.each do |val|
			dependencies[val] = options_for_parent_value(val).map do |option|
				[option.value, option.label]
			end
		end

		dependencies
	end

	def options_for_parent_value(val)
		client.get_options("#{name}_v", 'value' => val, 'field' => dependent_on)
	end

	def mapping
		MAPPING[name] or raise "Combo field #{name} unrecognized; need to be configured."
	end
end
