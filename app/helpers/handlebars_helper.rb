module HandlebarsHelper
  def add_handlebars_template(name, id=nil)
    id = name.gsub('_', '-') unless id

    html = ["<script id='"]
    html << id
    content_security_policy_nonce
    html << "-template' nonce='#{content_security_policy_nonce}' type='text/x-handlebars-template'>"
    path = Rails.root.join('app', 'templates', "#{name}.handlebars") 
    #NOTE: Simply calling `render template` here without doing a lookup context-based call causes a missing template error.  By using the custom #locate_template method below, we're mimicking the fallback template logic Rails 6.0 uses.  See Rails source here: https://github.com/rails/rails/blob/6-0-stable/actionview/lib/action_view/renderer/template_renderer.rb#L28-L32
    html << render(template: locate_template(path))
    html << '</script>'
    html.join('').html_safe
  end

  private

  def locate_template(name)
    lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)
    lookup_context.with_fallbacks.find_template(name)
  end

end
