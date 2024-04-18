module ConditionsHelper
  def valid_search?
    !params[:conditions] || clean_search_path?
  end

  def clean_search_path?
    request.fullpath == clean_search_path
  end

  def clean_search_path
    case @search.class.to_s
    when "Search::Document"
      documents_search_path(cleaned_params)
    when "Search::PublicInspection"
      public_inspection_search_path(cleaned_params)
    end
  end

  private

  def cleaned_params
    shared_search_params.merge(
      conditions: clean_conditions(@search.valid_conditions),
      format: params[:format]
    )
  end

  def clean_conditions(conditions)
    if conditions.is_a?(Hash)
      conditions.each do |k,v|
        conditions[k] = clean_conditions(v) if v.is_a?(Hash)
        conditions[k] = v.reject{|x| x.blank?} if v.is_a?(Array)
      end

      conditions.delete_if do |k,v|
        if v.is_a?(Array)
          v.empty? || v.join("").empty?

        else
          v.blank?
        end
      end
    end

    # within needs a location to be used
    if conditions.present? && conditions[:near] && !conditions[:near][:location]
      conditions.delete(:near)
    end

    conditions
  end

  def shared_search_params
    params.slice(:page, :order, :fields, :per_page, :maximum_per_page, :include_pre_1994_docs, :search_type_ids)
  end
end
