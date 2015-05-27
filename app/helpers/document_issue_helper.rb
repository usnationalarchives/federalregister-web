module DocumentIssueHelper
  def issue_pdf_url(date)
    "http://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end

  def display_hierarchy(docs, agency, options={})
    document_partial = options[:document_partial]
    level = options[:level]
    docs.group_by{|doc| doc["subject_#{level}"]}.map do |subject_heading, docs|
      docs_only_at_this_level, nested_docs = docs.partition{|x| x["subject_#{level+1}"].nil?}
      tags = []
      tags << content_tag("h#{level+3}", subject_heading, class: "toc-subject-level") if nested_docs.present?
      tags << content_tag(:div, class: "toc-subject-level toc-level-#{level}") do
        str = []
        docs_only_at_this_level.each do |doc|
          str << render(partial: document_partial,
            locals: {
              subject: subject_heading,
              documents: agency.load_documents(doc["document_numbers"])
              })
        end
        str << display_hierarchy(nested_docs, agency, options={level: level+1, document_partial: document_partial}) if nested_docs.present?
        str.join("\n").html_safe
      end
    end.join("\n").html_safe
  end

end
