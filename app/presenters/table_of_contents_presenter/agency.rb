# encoding: utf-8
class TableOfContentsPresenter::Agency
  attr_reader :attributes, :presenter

  def initialize(attributes, presenter)
    @attributes = attributes
    @presenter = presenter
  end

  # override inspect to not show the parent presenter attributes
  def to_s
    vars = self.instance_variables.reject{|iv| iv == :@presenter}.
      map{|v| "#{v}=#{instance_variable_get(v).inspect}"}.join(", ")
    "<#{self.class}: #{vars}>"
  end

  def name
    attributes['name']
  end

  def slug
    attributes['slug'].present? ? attributes['slug'] : generated_slug
  end

  # if an agency was found when creating the toc json then it's slug
  # will be empty and we need to generate a placeholder - we may be able
  # to find it if the error was simple (commas, emdash, etc.)
  def generated_slug
    name.downcase.gsub(/-|,|:|;|—|\s/, '-').gsub(',','')
  end

  def toc_anchor(type=nil)
    type = type.downcase.gsub(' ', '-') if type
    [type, slug].compact.join('-')
  end

  def to_param
    slug
  end

  def child_agencies
    if attributes['see_also']
      @child_agencies ||= attributes['see_also'].map do |child_agency|
        agency_representation = TableOfContentsPresenter::Agency.new(child_agency, presenter)

        # normal case: corresponding agency from the presenter exists - return it
        # edge case: agency is mispelled, etc and we can't find it - return a stub
        presenter.agencies[agency_representation.slug] || agency_representation
      end
    else
      []
    end
  end

  def document_categories
    attributes["document_categories"]
  end

  def document_categories=(filtered_document_categories)
    attributes["document_categories"] = filtered_document_categories
  end

  def see_also
    attributes["see_also"]
  end

  def see_also=(filtered_see_alsos)
    attributes["see_also"] = filtered_see_alsos
  end

  def document_count_with_child_agencies
    return @document_count_with_child_agencies if @document_count_with_child_agencies

    @document_count_with_child_agencies = child_agencies.inject(document_count) do |sum, child_agency|
      sum += child_agency.document_count
      sum
    end
  end

  def document_count
    return @document_count if @document_count
    # if we couldn't find a corresponding agency in child agencies
    # above it won't have all the attributes
    return 0 unless attributes["document_categories"]

    @document_count = attributes["document_categories"].inject(0) do |sum, doc_cat|
      doc_cat["documents"].each do |doc|
        sum += doc["document_numbers"].size
      end
      sum
    end
  end

  def load_documents(doc_numbers)
    doc_numbers.map do |doc_num|
      doc = documents[doc_num]

      if doc.nil? && presenter.filtering_documents?
        nil
      else
        unless doc
          Honeybadger.notify(
            error_class: "Missing document number for table of contents",
            error_message: "Document number #{doc_num} not found for #{name}"
          )
        end

        doc.nil? ? doc_num : doc
      end
    end.compact
  end

  private

  def document_numbers
    return @document_numbers if @document_numbers
    doc_numbers = []
    attributes["document_categories"].each do |doc_cat|
      doc_cat["documents"].each do |doc|
        doc_numbers << doc["document_numbers"]
      end
    end
    @document_numbers = doc_numbers.flatten
  end

  def documents
    @documents ||= document_numbers.inject({}) do |hsh, doc_num|
      hsh[doc_num] = presenter.documents.find{|doc| doc.document_number == doc_num}
      hsh
    end
  end
end
