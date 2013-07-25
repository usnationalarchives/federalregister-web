class EmailHighlight
  attr_accessor :weight

  HIGHLIGHTS = YAML::load_file(Rails.root.join('data', 'email_highlights.yml'))

  def self.weight_hash
    @weight ||= highlights.inject( Hash.new{|h,k| h[k]=[] } ) do |h, highlight|
                  h[highlight.id] = highlight.priority
                  h
                end
  end

  def self.pick(num)
    pickup = Pickup.new(weight_hash, :uniq => true)
    picked = pickup.pick(num)

    highlights.select{|h| picked.include?(h.id)}
  end

  def self.highlights
    @highlights ||= HIGHLIGHTS.map do |h|
      next unless h['enabled'] == true

      highlight =  OpenStruct.new(:id       => h['id'],
                              :created  => h['created'],
                              :title    => h['title'],
                              :image    => h['image'],
                              :content  => h['content'],
                              :priority => h['priority'],
                              :enabled  => h['enabled'])
      highlight
    end.compact
  end
end
