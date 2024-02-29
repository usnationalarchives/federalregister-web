class XsltFunctions
  include GpoImages::ImageIdentifierNormalizer

  # GPO will occassionally include multiple footnotes in a single node
  # we need to break them out in order to link them properly.
  def footnotes(nodes, page_number)
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
            href: "#footnote-#{footnote}-p#{page_number}",
            id: "citation-#{footnote}-p#{page_number}"
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
    return blank_document.children unless nodes.present?

    topics = ListOfSubjectsTopicParser.parse(nodes.first.content)

    document = blank_document
    Nokogiri::XML::Builder.with(document) do |doc|
      doc.ul(
        class: 'subject-list'
      ) {
        topics.each do |topic|
          doc.li {
            doc.text topic
          }
        end
      }
    end

    document.children
  end

  def amendment_part(nodes)
    if nodes.first.class == Nokogiri::XML::Text
      node_text = nodes.first.content

      match = node_text.strip.match(/^(\d+\.) (.*)/)
      css_class = 'amendment-part-number'

      unless match
        match = node_text.strip.match(/^([a-z]\.) (.*)/)
        css_class = 'amendment-part-subnumber'
      end

      if match
        document = blank_document
        part_number, part_text = match[1], match[2]

        Nokogiri::XML::Builder.with(document) do |doc|
          doc.span(class: css_class) {
            doc.text "#{part_number} "
          }

          doc.text "#{part_text} "
        end

        # remove the first text node that we're replacing
        # with our marked up version
        nodes.shift
        nodes = prepend_nodes(nodes, document.children)
      end
    end

    nodes
  end

  def gpo_image(nodes, link_id, image_class, data_width, data_height, images, document_number, publication_date)
    document = blank_document
    images = images.split(' ')

    graphic_identifier = normalize_image_identifier(
      Addressable::URI.escape(nodes.first.content)
    )
    fallback_url = "https://#{Settings.s3_buckets.image_variants}/#{graphic_identifier}/#{graphic_identifier}_original_size.png"
    begin
      image_variants = ImageVariant.find(graphic_identifier)

      original_size_image_variant = image_variants.find { |x| x.style == "original_size" }

      image = if original_size_image_variant
        original_size_image_variant
      else
        image_variants.first
      end
    rescue FederalRegister::Client::RecordNotFound
      image = ImageVariant.new('url' => fallback_url)
      # Stub out url with expected image such that when it's available
      # we don't need to reprocess. This will break if images url is not
      # the expected one (eg changes at some point in future)
    rescue => e
      image = ImageVariant.new('url' => fallback_url)
      Honeybadger.notify(e, context: {identifier: graphic_identifier})
    end

    Nokogiri::XML::Builder.with(document) do |doc|
      doc.a(
        class: "document-graphic-link",
        id: link_id,
        href: image.url,
        'data-col-width' => data_width,
        'data-height' => data_height
      ) {
        doc.img(
          :class => image_class,
          :loading => 'lazy',
          :src => image.url,
          :style => "max-height: #{(1.29 * data_height.to_i).to_i}px"
        )
      }
    end

    document.children
  end

  def capitalize_most_words(nodes)
    nodes.first.content.downcase.capitalize_most_words
  end

  def convert_table(nodes)
    table = nodes.first
    nodes.shift
    nodes.push(
      Nokogiri::HTML(
        HtmlCompilator::Tables::Table.new(table).to_html
      )
    )
  end

  private

  def blank_document
    Nokogiri::XML::DocumentFragment.parse ""
  end

  def prepend_nodes(nodeset, nodes)
    # insert new nodes in reverse order (the only method we have is push)
    nodeset = nodeset.reverse
    nodes.reverse.each{|x| nodeset.push(x) }

    # reverse to get our desired order
    nodeset.reverse
  end

  def graphic_url(size, graphic_identifier)
    "https://#{Settings.s3_buckets.public_images}/#{graphic_identifier}/#{size}.png"
  end
end
