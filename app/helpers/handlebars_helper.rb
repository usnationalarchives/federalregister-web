module HandlebarsHelper
  def add_handlebars_template(name, id)
    html = ['<script id="']
    html << id
    html << '-template" type="text/x-handlebars-template">'
    html << render( :file => File.join(File.dirname(__FILE__), '..', 'templates', "#{name}.handlebars.erb") )
    html << '</script>'
    html.join('').html_safe
  end
end
