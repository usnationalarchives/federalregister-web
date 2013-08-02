class EmailHighlight
  class EmailHighlightError < StandardError; end

  attr_accessor :weight

  HIGHLIGHTS = YAML::load_file(Rails.root.join('data', 'email_highlights.yml'))['highlights']

  def self.calculate_weight_hash(exclude = [])
    if exclude.empty?
      highlights = rotatable_highlights
    else 
      highlights = rotatable_highlights - exclude
    end

    highlights.inject( Hash.new{|h,k| h[k]=[] } ) do |h, highlight|
      h[highlight.name] = highlight.priority
      h
    end
  end

  def self.pick(num, options={})
    if options[:exclude]
      weight_hash = calculate_weight_hash(options[:exclude].to_a)
    else
      weight_hash = calculate_weight_hash
    end

    pickup = Pickup.new(weight_hash, :uniq => true)
    picked = pickup.pick(num)

    chosen_highlights = rotatable_highlights.select{|h| picked.include?(h.name)}
  end

  def self.rotatable_highlights
    @rotatable_highlights ||= highlights.select{|h| h.in_rotation == true}
  end

  def self.highlights
    @highlights ||= HIGHLIGHTS.map do |h|
      next unless h['enabled']

      highlight =  EmailHighlight.new(:name    => h['name'],
                                     :created  => h['created'],
                                     :title    => h['title'],
                                     :image    => h['image'],
                                     :content  => h['content'],
                                     :priority => h['priority'],
                                     :enabled  => h['enabled'],
                                     :in_rotation => h['in_rotation'])
      highlight
    end.compact
  end

  attr_accessor :content, :created, :enabled, :image, :in_rotation, :name, :priority, :title
  def initialize(args={})
    @name     = args[:name]
    @created  = args[:created]
    @title    = args[:title]
    @image    = args[:image]
    @content  = args[:content]
    @priority = args[:priority]
    @enabled  = args[:enabled]
    @in_rotation = args[:in_rotation]
  end

  def self.find(name, options = {})
    highlight = highlights.select{|h| h.name == name}.first

    return nil unless highlight
    return nil if highlight.enabled == false unless options[:disabled]

    highlight
  end

  def self.selected_highlight(name)
    highlight = find(name)
    handle_missing_highlight(highlight, name) if highlight.nil?
    highlight
  end

  def self.highlights_with_selected(number, selected_highlight_name, options={})
    highlight = selected_highlight(selected_highlight_name)
    random_highlights = pick(number, :exclude => highlight)

    [highlight, random_highlights].flatten
  end

  private

  def self.handle_missing_highlight(highlight, name)
    message = "Attempt to use missing or disabled highlight '#{name}' as selected highlight"

    if Rails.env == "production"
      Airbrake.notify(message)
    else
      raise EmailHighlightError, message
    end
  end

  def self.valid_definition?(highlight_definition)
    highlight_definition['name'].present? &&
      highlight_definition['created'].present? &&
      highlight_definition['title'].present? &&
      highlight_definition['image'].present? &&
      highlight_definition['content'].present? &&
      highlight_definition['priority'].present? &&
      highlight_definition['enabled'].to_s.present? &&  #boolean value
      highlight_definition['in_rotation'].to_s.present? #boolean value
  end

end
