module DocumentDecorator::FrArchives
  FR_ARCHIVES_VOLUMES = (45..58)

  def fr_archives_sensitive_html_url
    if in_archives?
      issue_slice_pdf_url
    else
      html_url
    end
  end

  def in_archives?
    FR_ARCHIVES_VOLUMES.include? volume
  end


  private

  def issue_slice_pdf_url
    FrArchivesCitation.new(volume, context.fetch(:volume_page_number)).pdf_url
  end

end
