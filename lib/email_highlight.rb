class EmailHighlight
  attr_accessor :weight

  HIGHLIGHTS = YAML::load_file(Rails.root.join('data', 'email_highlights.yml'))

  def self.weight_hash
    @weight ||= HIGHLIGHTS.inject( Hash.new{|h,k| h[k]=[] } ) do |h, highlight|
                  h[highlight['id']] = highlight['priority']
                  h
                end
  end

  def self.pick(num)
    pickup = Pickup.new(weight_hash, :uniq => true)
    picked = pickup.pick(num)

    highlights = HIGHLIGHTS.select{|h| picked.include?(h['id'])}
  end
end
