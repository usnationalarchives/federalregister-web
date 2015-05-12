class HtmlCompilator::Tables::Table
  include ActionView::Helpers::TagHelper

  attr_reader :node

  def self.compile(xml_file_path)
    file = File.open(xml_file_path)
    node = Nokogiri::XML(file).root
    new(node).to_html
  end

  def initialize(node)
    @node = node
  end

  def to_html
    h.content_tag(:div, :class => "table-wrapper") {
      h.content_tag(:table, :class => table_classes.join(' '), data: {point_width: total_width_in_points}) {
        h.concat h.content_tag(:caption) {
          captions.each do |caption|
            h.concat caption.to_html
          end
        } if captions.present?

        h.concat h.content_tag(:thead) {
          header_rows.each do |row|
            h.concat row.to_html
          end
        }

        h.concat h.content_tag(:tbody) {
          body_rows.each do |row|
            h.concat row.to_html
          end
        }

        h.concat h.content_tag(:tfoot) {
          footers.each do |footer|
            h.concat footer.to_html
          end
        } if footers.present?
      }
    }
  end

  def columns
    @columns ||= HtmlCompilator::Tables::Column.generate(:table => self)
  end

  def captions
    @captions ||= HtmlCompilator::Tables::Caption.generate(:table => self)
  end

  def footers
    @footers ||= HtmlCompilator::Tables::Footer.generate(:table => self)
  end

  def header_rows
    @header_rows ||= HtmlCompilator::Tables::HeaderRow.generate(:table => self, :node => node.xpath('BOXHD'))
  end

  def body_rows
    @body_rows ||= node.css('ROW').map do |row_node|
      HtmlCompilator::Tables::BodyRow.new(:table => self, :node => row_node)
    end
  end

  def num_columns
    columns.size
  end

  def table_classes
    [].tap do |classes|
      classes << 'wide' if total_width_in_points > 250
    end
  end

  def total_width_in_points
    columns.sum(&:width_in_points)
  end

  def h
    @h ||= ActionView::Base.new
  end

  def transform(xml)
    @text_transformer ||= Nokogiri::XSLT(
      File.read("#{Rails.root}/app/views/xslt/matchers/table_contents.html.xslt")
    )
    @text_transformer.transform(Nokogiri::XML(xml)).to_s.strip.html_safe
  end

  def options
    # handle options with parens, like OPTS="L2(1,2,3),4"
    @options ||= (node.attr("OPTS") || '').split(/,(?![^\(]*\))/)
  end

  def rule_option
    options.
      detect{|x| x =~ /^L\d(?:\(|$)/ }
  end

  def rules
    return @rules if @rules
    if rule_option
      @rules = case rule_option.sub(/\(.*\)/,'')
      when "L0"
        []
      when "L1"
        [:horizonal]
      when "L2"
        [:horizonal, :down]
      when "L3"
        [:horizonal, :side]
      when "L4"
        [:horizonal, :down, :side]
      when "L5"
        # documented as "trim side only", but not really in use
        #  and doesn't make sense on the web
        [:horizonal, :side]
      when "L6"
        # documented as "trim side only", but not really in use
        #  and doesn't make sense on the web
        [:horizonal, :down, :side]
      else
        raise "invalid rule option #{rule_option}"
      end
    else
      @rules = [] # not specified; what is the default?
    end
  end

  def top_border_style
    case rule_widths[0]
    when 0
      nil
    when 4,5,10
      :single
    when 20
      :bold
    else
      :single
    end
  end

  def rule_widths
    rule_widths = [10,3,3,5,4,3]
    if rule_option && rule_option =~ /\(/
      values = rule_option.sub(/^.*\(/, '').sub(/\)/, '').split(',')
      values.each_with_index do |v, i|
        rule_widths[i] = v.to_i if v.present?
      end
    end

    rule_widths
  end
end
