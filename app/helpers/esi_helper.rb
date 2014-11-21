module EsiHelper
  def esi(path)
    "<esi:include src=\"#{path}\" />".html_safe
  end
end
