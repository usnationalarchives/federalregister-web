class SuggestionDecorator < ApplicationDecorator
  extend Memoist

  include ActionView::Helpers::NumberHelper

  delegate_all

  # def citation
  #   object.hierarchy.citation
  # end

  # delegation is broken here and delegates to a route builder route
  # instead of to the object as expected
  def table_of_contents_path
    object.table_of_contents_path
  end

  def highlighted_citation
    return h.highlight(citation, citation) if supports_simple_highlight?

    terms = [@context[:query]]

    # query may include shorthand
    if @context[:query].include?("/")
      terms << @context[:query].gsub(/\s*\/\s*/, " CFR ")
      terms << @context[:query].gsub(/\s*\/\s*/, " CFR Part ")
    end
    terms << "CFR" if @context[:query].include?("C.F.R")

    # query may include paragraph details
    paren_fragments = @context[:query].split(/(?=[(])/)
    if paren_fragments.count > 1
      (paren_fragments.count - 2).downto(0).each do |index|
        terms << paren_fragments[..index].join
      end
    end

    terms.concat(@context[:query].split(/[\s\/]/))
    terms.compact_blank!
    # terms = terms.map { |term| Dashes.permute(term).to_a }.flatten
    terms = terms.flatten

    highlighted = h.highlight(citation, terms.uniq)
    highlighted.gsub("</mark> <mark>", " ").html_safe
  end

  def supports_simple_highlight?
    object.type == "custom"
  end

  def removed_description
    if object.removed
      I18n.t(
        "cfr_reference.removed",
        removed: object.removed.strftime("%-m/%-d/%Y")
      )
    end
  end
  memoize :removed_description

  def row_classes
    class_str = %i[suggestion]
    class_str << object.type
    class_str << :reserved if object.reserved?
    class_str << :removed if object.removed
    class_str.map(&:to_s).join(" ")
  end

  def display_toc_link?
    false
    # hierarchy.supports_toc?
  end

  def highlight_colspan
    display_toc_link? ? 1 : 2
  end

  def usable_highlight
    highlight = object.highlight || guess_highlight

    return unless highlight.present?
    return highlight if highlight.include?("<mark>") || !@context[:query].present?

    h.highlight(
      highlight,
      highlight.include?(@context[:query]) ? @context[:query] : @context[:query].split(" ")
    )
  end

  private

  def guess_highlight
    return nil unless object.type == "cfr_reference"

    leaf = object.hierarchy.leaf
    [
      object.hierarchy_headings.respond_to?(leaf) ? object.hierarchy_headings.send(leaf) : "",
      object.headings.respond_to?(leaf) ? object.headings.send(leaf) : ""
    ].compact.join(" ")
  end
end
