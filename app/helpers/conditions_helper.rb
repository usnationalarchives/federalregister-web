module ConditionsHelper
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
    conditions
  end

  def blank_conditions?(conditions)
    return false if conditions.nil?
    if conditions.is_a?(Hash)
      conditions.detect do |k,v|
        if conditions.is_a?(Hash)
          v.blank? || blank_conditions?(v)
        elsif conditions.is_a?(Array)
          v.empty? || v.join("").empty?
        else
          v.blank?
        end
      end
    elsif conditions.is_a?(Array)
      conditions.blank? || conditions.join("").empty?
    else
      conditions.blank?
    end
  end
end
