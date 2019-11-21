module HandlebarsHelper
  def add_handlebars_template(name, id=nil)
    id = name.gsub('_', '-') unless id

    html = ['<script id="']
    html << id
    html << '-template" type="text/x-handlebars-template">'
    html << render(file: Rails.root.join('app', 'templates', "#{name}.handlebars"))
    html << '</script>'
    html.join('').html_safe
  end
end
