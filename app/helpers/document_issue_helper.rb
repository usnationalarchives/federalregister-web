module DocumentIssueHelper
  include RouteBuilder

  def issue_pdf_url(date)
    fdsys_document_issue_pdf_url(date)
  end

  def display_hierarchy(docs, agency, options={})
    document_partial = options[:document_partial]
    level = options[:level]
    docs.group_by{|doc| doc["subject_#{level}"]}.map do |subject_heading, docs|
      docs_only_at_this_level, nested_docs = docs.partition{|x| x["subject_#{level+1}"].nil?}

      tags = []

      # we want the last level of hierarchy to be linked unless it represents multiple documents
      if subject_heading_required?(level, docs_only_at_this_level, nested_docs)
        if nested_docs.empty? && docs_only_at_this_level.size == 1
          header = link_to subject_heading,
            url_for_subject_heading(agency, docs_only_at_this_level)
        else
          header = subject_heading
        end

        tags << content_tag("h#{level+3}", header, class: "toc-subject-level")
      end

      tags << content_tag(:div, class: "toc-subject-level toc-level-#{level}") do
        str = []
        docs_only_at_this_level.each do |doc|
          str << render(
            partial: document_partial,
            locals: {
              subject: subject_heading_required?(level, docs_only_at_this_level, nested_docs) ? nil : subject_heading,
              documents: agency.load_documents(doc["document_numbers"])
            }
          )
        end
        str << display_hierarchy(nested_docs, agency, options={level: level+1, document_partial: document_partial}) if nested_docs.present?
        str.join("\n").html_safe
      end
    end.join("\n").html_safe
  end

  def subject_heading_required?(level, docs_only_at_this_level, nested_docs)
    level == 1 || (docs_only_at_this_level.present? && nested_docs.present?)
  end

  def url_for_subject_heading(agency, docs_only_at_this_level)
    agency.load_documents(
      docs_only_at_this_level.first["document_numbers"]
    ).first.html_url
  end
end
