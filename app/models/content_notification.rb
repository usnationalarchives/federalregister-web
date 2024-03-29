# valid types: basic, info, danger, feature, success, warning
class ContentNotification
  attr_reader :actions, :hidden, :icon, :id, :link, :options, :text, :type

  def initialize(text:, actions: nil, icon: nil, link: nil, type: :basic, hidden: nil, id: nil, options: {})
    @actions = actions
    @hidden = hidden
    @icon = icon
    @id = id
    @link = link
    @options = options
    @text = text
    @type = type
    @type = :danger if type == "error"
  end

  def closable?
    options.fetch(:closable, false)
  end

  # used by closable types to keep them hidden across a user's session
  #  primarily used by the feature type
  def trackable_id
    Digest::SHA1.hexdigest(type.to_s + text)[0..7]
  end
end
