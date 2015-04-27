class XsltFunctions
  # GPO will occassionally include multiple footnotes in a single node
  # we need to break them out in order to link them properly.
  def multiple_footnotes(nodes)
    footnotes = nodes.first.content.split(' ')

    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.sup {
        doc.text "["

        footnotes.each do |footnote|
          doc.a(
            class: "footnote-reference",
            href: "#footnote-#{footnote}"
          ) {
            doc.text footnote
          }

          doc.text ", " if footnotes.last != footnote
        end
        doc.text "] "
      }
    end

    document.children
  end

  def list_of_subjects(nodes)
    topics = nodes.first.content.split(',').map{|t| t.strip.gsub('.', '')}

    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.ul {
        topics.each do |topic|
          doc.li {
            doc.a(
              href: "/topics/#{topic.downcase.gsub(' ', '-')}"
            ) {
              doc.text topic
            }
          }
        end
      }
    end

    document.children
  end

  private

  def blank_document
    Nokogiri::XML::DocumentFragment.parse ""
  end
end
