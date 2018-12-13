module DocumentIssueHelper
  include RouteBuilder

  def issue_pdf_url(date)
    govinfo_document_issue_pdf_url(date)
  end

  def display_hierarchy(docs, agency, options={})
    document_partial = options[:document_partial]
    level = options[:level]
    fr_index = options.fetch(:fr_index, false)
    total_document_count = options[:total_document_count]

    docs.group_by{|doc| doc["subject_#{level}"]}.map do |subject_heading, docs|
      # we don't expect more than 3 levels of hierarchy in any toc, so check the next two for subject content
      docs_only_at_this_level, nested_docs = docs.partition{|x| x["subject_#{level+1}"].nil? && x["subject_#{level+2}"].nil?}

      tags = []

      if subject_heading_required?(level, docs_only_at_this_level, nested_docs)
        header = fr_index && docs_only_at_this_level.present? ? render_fr_index_subject_header(subject_heading, agency, docs_only_at_this_level) : subject_heading

        tags << content_tag("h#{level+3}", header, class: "toc-subject-level")
      end

      tags << content_tag(:div, class: "toc-subject-level toc-level-#{level}") do
        str = []
        docs_only_at_this_level.each do |doc|
          str << render(
            partial: document_partial,
            locals: {
              subject: subject_heading_required?(level, docs_only_at_this_level, nested_docs) ? nil : subject_heading,
              documents: agency.load_documents(doc["document_numbers"]),
              total_document_count: total_document_count
            }
          )
        end
        str << display_hierarchy(nested_docs, agency, options={level: level+1, document_partial: document_partial, fr_index: fr_index, total_document_count: total_document_count}) if nested_docs.present?
        str.join("\n").html_safe
      end
    end.join("\n").html_safe
  end

  def display_hierarchy_as_text(docs, agency, options={})
    document_partial = options[:document_partial]
    level = options[:level]
    total_document_count = options[:total_document_count]

    docs.group_by{|doc| doc["subject_#{level}"]}.map do |subject_heading, docs|
      docs_only_at_this_level, nested_docs = docs.partition{|x| x["subject_#{level+1}"].nil? && x["subject_#{level+2}"].nil?}

      tags = []

      if subject_heading_required?(level, docs_only_at_this_level, nested_docs)
        header = subject_heading

        tags << "#{' ' * (level*2)}#{header}"
      end

      str = []
      docs_only_at_this_level.each do |doc|
        str << "#{' ' * (level*2)}" + render(
          partial: document_partial,
          locals: {
            subject: subject_heading_required?(level, docs_only_at_this_level, nested_docs) ? nil : subject_heading,
            documents: agency.load_documents(doc["document_numbers"]),
            total_document_count: total_document_count
          }
        )
      end

      str << display_hierarchy_as_text(nested_docs, agency, options={level: level+1, document_partial: document_partial, total_document_count: total_document_count}) if nested_docs.present?

      tags << str.join("\n").html_safe

    end.join("\n").html_safe
  end

  def subject_heading_required?(level, docs_only_at_this_level, nested_docs)
    level == 1 || (docs_only_at_this_level.present? || nested_docs.present?)
  end

  def url_for_subject_heading(agency, docs_only_at_this_level)
    agency.load_documents(
      docs_only_at_this_level.first["document_numbers"]
    ).first.try(:html_url)
  end

  def render_fr_index_subject_header(subject, agency, docs_only_at_this_level)
    documents = agency.load_documents(docs_only_at_this_level.first["document_numbers"])

    header = render partial: 'indexes/subject_header_with_documents', locals: {
      subject: subject,
      documents: documents
    }

    header
  end
end
