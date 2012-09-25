class RegulationsDotGov::Document < RegulationsDotGov::GenericDocument
  def document_id
    @raw_attributes['documentId']
  end

  def docket_id
    @raw_attributes['docketId']
  end

  def title
    @raw_attributes['title']
  end

  def comment_due_date
    val = @metadata["Comment Due Date"]
    if val.present?
      DateTime.parse(val)
    end
  end

  def comment_url
    if @raw_attributes['canCommentOnDocument']
      "http://www.regulations.gov/#!submitComment;D=#{document_id}"
    end
  end

  def url
    "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
  end
end
