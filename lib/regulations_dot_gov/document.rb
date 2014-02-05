class RegulationsDotGov::Document < RegulationsDotGov::GenericDocument
  def document_id
    raw_attributes['documentId']
  end

  def docket_id
    raw_attributes['docketId']
  end

  def title
    raw_attributes['title']
  end

  def comment_due_date
    val = raw_attributes["commentEndDate"]
    if val.present?
      DateTime.parse(val)
    end
  end

  def comment_url
    if raw_attributes['canComment']
      "http://www.regulations.gov/#!submitComment;D=#{document_id}"
    end
  end

  def url
    "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
  end

  def comment_count
    raw_attributes['numberOfCommentReceived']
  end

  def federal_register_document_number
    raw_attributes['frNumber']
  end
end
