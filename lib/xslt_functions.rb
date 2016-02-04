class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  # GPO will occassionally include multiple footnotes in a single node
  # we need to break them out in order to link them properly.
  def footnotes(nodes)
    footnotes = nodes.first
    # sometimes XML will have FTRF that follow blank nodes so just return
    return blank_document.children unless footnotes

    footnotes = footnotes.content.split(' ')

    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.sup {
        doc.text "["

        footnotes.each do |footnote|
          doc.a(
            class: "footnote-reference",
            href: "#footnote-#{footnote}",
            id: "citation-#{footnote}"
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
      doc.ul(
        class: 'subject-list'
      ) {
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

  def amendment_part(nodes)
    return "" unless nodes.present?

    document = blank_document

    node_text = nodes.first.content
    match = node_text.strip.match(/^(\d+\.) (.*)/)

    if match
      part_number, part_text = match[1], match[2]

      Nokogiri::XML::Builder.with(document) do |doc|
        doc.span(class: 'amendment-part-number') {
          doc.text part_number
        }
        doc.span(class: 'amendment-part-text') {
          doc.text " #{part_text}"
        }
      end
    else
      Nokogiri::XML::Builder.with(document) do |doc|
        doc.text node_text
      end
    end

    document.children
  end

  def missing_graphic(nodes, document_number, publication_date)
    document = blank_document
    node_text = nodes.first.content

    Honeybadger.notify(
      error_class: 'HTML::Compilator',
      error_message: "Missing Graphic #{node_text} for FR Doc #{document_number} on #{publication_date}",
      parameters: {
        graphic_identifier: node_text,
        document_number: document_number,
        publication_date: publication_date
      }
    )

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.p(class: 'missing-graphic') {
        doc.text "[Missing Graphic #{node_text}]"
      }
    end

    document.children
  end

  def gpo_image(nodes, link_id, image_class, data_width, data_height)
    document = blank_document

    graphic_identifier = normalize_image_identifier(
      nodes.first.content
    )

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        class: "document-graphic-link",
        id: link_id,
        href: graphic_url('original', graphic_identifier),
        'data-width' => data_width,
        'data-height' => data_height
      ) {
        doc.img(
          :class => image_class,
          :src => graphic_url('large', graphic_identifier)
        )
      }
    end

    document.children
  end

  def capitalize(nodes)
    nodes.first.content.upcase
  end

  private

  def blank_document
    Nokogiri::XML::DocumentFragment.parse ""
  end

  def graphic_url(size, graphic_identifier)
    "https://s3.amazonaws.com/#{Settings.s3_buckets.public_images}/#{graphic_identifier}/#{size}.png"
  end
end
