class SearchDetails
  attr_reader :conditions

  def initialize(conditions)
    @conditions = conditions || {}
  end

  def response
    @response ||= HTTParty.get(
      "#{Settings.federal_register.api_url}/documents/search-details/?#{{conditions: conditions}.to_param}"
    )
  end

  def suggestions
    @suggestions ||= response["suggestions"].map do |type, details|
      Suggestion.build(type, details, conditions)
    end.compact.reverse
  end

  def matching_entry_citation
    suggestions.detect{|x| x.is_a?(SearchDetails::Suggestion::Citation)}
  end

  def entry_with_document_number
    suggestions.detect{|x| x.is_a?(SearchDetails::Suggestion::DocumentNumber)}
  end

  def filters
    if response["filters"].present?
      @filters ||= response["filters"].keys.map do |filter_type|
        Filter.new(filter_type, response["filters"][filter_type])
      end
    end
  end

  class Filter
    attr_reader :value, :condition, :name_or_names
    def initialize(condition, options)
      @condition = condition
      @value = options.delete("value")
      @name_or_names = options.delete("name")
    end

    def name
      if name_or_names.is_a?(Array)
        name_or_names.join(", ")
      else
        String(name_or_names)
      end
    end
  end

  class Suggestion
    def self.build(type, details, conditions)
      if CLASSES[type]
        CLASSES[type].new(details, conditions)
      end
    end

    def to_partial_path
      "search/documents/suggestions/#{self.class.name.underscore.split("/").last}"
    end

    class SearchRefinement < Suggestion
      attr_reader :conditions, :count, :search_summary, :search_conditions
      def initialize(options, conditions)
        @conditions = conditions
        @search_conditions = options["search_conditions"]
        @count = options["count"]
        @search_summary = options["search_summary"]
      end
    end

    class Citation < Suggestion
      attr_reader :document_numbers, :conditions

      CITATION_TYPES = {
        'USC' => /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/,
        'CFR' => /(\d+)\s+CFR\s+(\d+)(?:\.(\d+))?/,
        'FR'  => /(\d+)\s+FR\s+(\d+)/,
        'FR-DocNum' => /(?:FR Doc(?:\.|ument)? )([A-Z0-9]+-[0-9]+)(?:[,;\. ])/i,
        'PL'  => /Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+)/,
        'EO'  => /(?:EO|E\.O\.|Executive Order) (\d+)/
      }

      def initialize(options, conditions)
        @document_numbers = options["document_numbers"]
        @conditions = conditions
      end

      def name
        conditions["term"]
      end

      def citation_type
        @citation_type ||= matching_fr_entries.each do |entry|
          return CITATION_TYPES.
            detect{|type, regexp| entry.citation.match(regexp)}.
            first
        end
      end

      def matching_fr_entries
        if document_numbers.count > 1
          FederalRegister::Document.find_all(document_numbers).map do |doc|
            DocumentDecorator.decorate(doc)
          end
        else
          Array(DocumentDecorator.decorate(FederalRegister::Article.find(document_numbers.first)))
        end
      end

      def part_1
        matching_fr_entries.first.citation.split(" ").first
      end

      def part_2
        matching_fr_entries.first.citation.split(" ").last
      end
    end

    class PublicInspection < Suggestion
      attr_reader :count, :conditions
      def initialize(options, conditions)
        @conditions = conditions
        @count = options["count"]
      end
    end

    class DocumentNumber < Suggestion
      attr_reader :document_number
      def initialize(options, conditions)
        @conditions = conditions
        @document_number = options["document_number"]
      end

      def document
        @document ||= DocumentDecorator.decorate(FederalRegister::Article.find(document_number))
      end
    end

    class CFR < Suggestion
      attr_reader :title, :part, :section, :conditions
      def initialize(options, conditions)
        @conditions = conditions
        @title = options["title"]
        @part = options["part"]
        @section = options["section"]
      end

      def name
        "#{title} CFR #{part}" + (section.blank? ? '' : ".#{section}")
      end
    end


    def public_inspection
      OpenStruct.new(
        count: suggestions["public_inspection"]["count"]
      )
    end

    CLASSES = {
      "document_number" => DocumentNumber,
      "cfr" => CFR,
      "search_refinement" => SearchRefinement,
      "citation" => Citation,
      "public_inspection" => PublicInspection
    }
  end
end
