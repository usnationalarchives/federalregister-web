module DocumentDecorator::Officialness
  def status_object
    if document?
      official? ? OfficialStatus.new(self) : UnofficialStatus.new(self)
    end
  end

  def official?
    Date.today >= Settings.officialness.start_date
  end

  def document?
    model.class.to_s == "Document"
  end

  class StatusObject
    attr_reader :decorator

    def initialize(decorator)
      @decorator = decorator
    end
  end

  class UnofficialStatus < StatusObject
    def doc_css_class
      'doc-published'
    end

    def doc_content_box(&block)
      decorator.h.fr_box("Published Document", :published, &block)
    end

    def doc_details_box(&block)
      decorator.h.fr_box_small("Document Details", :published_doc_details, &block)
    end
  end

  class OfficialStatus < StatusObject
    def doc_css_class
      'doc-official'
    end

    def doc_content_box(&block)
      decorator.h.fr_box("Published & Authenticated Document", :official, header: {seal: true}, &block)
    end

    def doc_details_box(&block)
      decorator.h.fr_box_small("Document Details", :official_doc_details, &block)
    end
  end
end
