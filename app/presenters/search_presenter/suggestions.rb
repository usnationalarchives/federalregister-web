class SearchPresenter::Suggestions
  include Rails.application.routes.url_helpers
  include RouteBuilder::Documents

  def initialize(suggestions)
    @suggestions = suggestions
  end

  SUGGESTIONS_ORDER = [
    "document_number_suggestion",
    "citation_suggestion",
    "search_refinement_suggestion",
    "cfr_suggestion",
    "public_inspection_suggestion",
    "explanatory_suggestion",
  ]

  def suggestions
    @suggestions
      .sort_by { |s| SUGGESTIONS_ORDER.index(suggestion_type(s)) }
      .map do |suggestion|
        self.send(suggestion_type(suggestion), suggestion)
      end
  end

  def suggestion_type(suggestion)
    suggestion.class.name.split("::").last.snakecase
  end

  def explanatory_suggestion(suggestion)
    ContentNotification.new(
      text: suggestion.text,
      actions: "",
      link: h.link_to("View", suggestion.link_url),
      type: :info,
      icon: 'link'
    )
  end

  def cfr_suggestion(suggestion)
    text = <<~TEXT
      <p>
        Searching for the Code of Federal Regulations
        citation: <span class="term">#{suggestion.name}</span>?
      </p>
    TEXT

    ContentNotification.new(
      text: text,
      link: h.link_to("View on eCFR.gov",
        FederalRegisterReferenceParser.ecfr_url(
          suggestion.title, suggestion.part),
        class: 'fr-ga-event',
        data: {
          event_name: 'fr_search_suggestion_click',
          event_parameters: {
            suggestion_type: 'cfr',
            suggestion_text: "#{suggestion.title} CFR #{suggestion.part}"
          }.to_json
        },
        target: "_blank"
      ),
      type: :success,
      icon: 'link'
    )
  end

  # this is a sub-type of citation suggestion not one currently returned by
  # API endpoint
  def archives_suggestion(suggestion)
    citation = FrArchivesCitation.new(suggestion.volume, suggestion.page)

    text = <<~TEXT
      <p>
        Searching for the citation
        <span class="term">#{suggestion.name}</span>?
    TEXT

    if citation.download_link_available?
      text += "</p>"
      action_text = <<~TEXT
        <p>
          The 1936-1994 official print volumes of the Federal Register have been
          digitalized and are available online in PDF format. We found the
          following matching items published on
          #{citation.publication_date.to_s(:month_day_year)}:
        </p>
      TEXT

      actions = h.content_tag("div", class: "matching-documents") do
        action_text.html_safe +
          h.content_tag("ul") do
            links = ""
            # we're unable to generate issue slices for some docs
            if citation.issue_slice_url
              links += h.content_tag("li") do
                h.link_to(
                  "Document View",
                  citation.issue_slice_url,
                  class: 'fr-ga-event',
                  data: {
                    event_name: 'fr_search_suggestion_click',
                    event_parameters: {
                      suggestion_type: 'fr_archives_document',
                      suggestion_text: suggestion.name
                    }.to_json
                  }
                ) +
                  " (#{h.number_to_human_size(citation.optimized_file_size)})"
              end
            end

            links += h.content_tag("li") do
              h.link_to(
                h.sanitize(
                  "Full issue containing #{suggestion.name}",
                  tags: %w(span),
                  attributes: %w(class)
                ),
                citation.gpo_url,
                class: 'fr-ga-event',
                data: {
                  event_name: 'fr_search_suggestion_click',
                  event_parameters: {
                    suggestion_type: 'fr_archives_issue',
                    suggestion_text: suggestion.name
                  }.to_json
                }
              ) +
                " (#{h.number_to_human_size(citation.original_file_size)})"
            end

            links.html_safe
          end
      end

      ContentNotification.new(
        text: text,
        actions: actions,
        link: "",
        type: :success,
        icon: 'documents'
      )
    else
      text += "Unfortunately, we were unable to find any documents with that citation.</p>"

      ContentNotification.new(
        text: text,
        link: "",
        type: :info,
        icon: 'documents'
      )
    end
  end

  def citation_suggestion(suggestion)
    return archives_suggestion(suggestion) unless suggestion.matching_fr_entries.present?

    if suggestion.citation_type == 'FR'
      match_text = suggestion.matching_fr_entries.count == 1 ? 'document' : 'documents'
    else
      match_text = "Executive Order"
    end

    text = <<~TEXT
      <p>
        Searching for the citation
        <span class="term">#{suggestion.name}</span>?
        The following #{match_text}
        #{suggestion.matching_fr_entries.count == 1 ? "appears" : "appear"}
        on page #{suggestion.part_2} of volume #{suggestion.part_1}:
      </p>
    TEXT

    actions = h.content_tag("div", class: "matching-documents") do
      h.content_tag("ul") do
        suggestion.matching_fr_entries.map do |document|
          h.content_tag("li") do
            path = document_path(document)
            if suggestion.page != document.start_page.to_s
              path << "#page-#{suggestion.page}"
            end

            html = <<~HTML
              <h5>
                #{h.link_to h.sanitize(document.title,
                    tags: %w(span), attributes: %w(class)),
                  path,
                  class: 'fr-ga-event',
                  data: {
                    event_name: 'fr_search_suggestion_click',
                    event_parameters: {
                      suggestion_type: 'citation',
                      suggestion_text: document.title
                    }.to_json
                  }
                }
              </h5>

              <ul class="metadata">
                <li>#{document.simple_metadata_description}</li>
                <li>
                  #{"Page".pluralize(document.pages)} #{document.page_range}
                  (#{h.pluralize(document.pages, "page")})
                </li>
              </ul>
            HTML
            html.html_safe
          end
        end.join("\n").html_safe
      end
    end

    ContentNotification.new(
      text: text,
      actions: actions,
      link: "",
      type: :success,
      icon: 'documents'
    )
  end

  def document_number_suggestion(suggestion)
    text = <<~TEXT
      <p>
        Searching for the document number
        <span class="term">#{suggestion.document_number}</span>?
      </p>
    TEXT

    ContentNotification.new(
      text: text,
      link: h.link_to("View Document",
        document_path(suggestion.document)
      ),
      type: :success,
      icon: 'document'
    )
  end

  def public_inspection_suggestion(suggestion)
    text = <<~TEXT
      <p>
        There #{suggestion.count == 1 ? 'is' : 'are'}
        #{h.pluralize(suggestion.count, "document")}
        scheduled for publication on Public Inspection that
        #{suggestion.count == 1 ? 'matches' : 'match' }
        your search.
      </p>
    TEXT

    path = public_inspection_search_path(conditions: suggestion.conditions)
    ContentNotification.new(
      text: text,
      link: h.link_to("View Results", path),
      path: path,
      type: :success,
      icon: 'clipboards',
      options: {
        html: {class: 'ga-exclude'}
      }
    )
  end

  def search_refinement_suggestion(suggestion)
    text = <<~TEXT
      <p>
        Searching for the #{h.pluralize(suggestion.count, "document")}
        #{CGI.unescapeHTML(suggestion.search_summary).html_safe}?
      </p>
    TEXT

    path = documents_search_path(conditions: suggestion.search_conditions)
    ContentNotification.new(
      text: text,
      link: h.link_to("View Results",
        path,
        class: 'fr-ga-event',
        data: {
          event_name: 'fr_search_suggestion_click',
          event_parameters: {
            suggestion_type: 'search_refinement',
            suggestion_text: CGI.unescapeHTML(
              suggestion.search_summary
            ).html_safe
          }.to_json
        }
      ),
      path: path,
      type: :success,
      icon: 'search'
    )
  end

  private

  def h
    ActionController::Base.helpers
  end
end
