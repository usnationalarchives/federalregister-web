# valid types: basic, info, danger, feature, success, warning
class ContentNotification
  attr_reader :actions, :hidden, :icon, :icon_label, :id, :link,
    :options, :text, :type, :path

  def initialize(text:, actions: nil, icon: nil, icon_label: nil,
    link: nil, path: nil, type: :basic, hidden: nil, id: nil, options: {})

    @actions = actions
    @hidden = hidden
    @icon = icon
    @icon_label = icon_label
    @id = id
    @link = link
    @options = options
    @path = path
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
