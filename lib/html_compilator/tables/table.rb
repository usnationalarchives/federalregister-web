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
    h.content_tag(:table, :border => 1) {
      h.concat h.content_tag(:caption) {
        captions.each do |caption|
          h.concat h.content_tag(:p, caption.body, class: caption.type)
        end
      } if captions.present?

      h.concat h.content_tag(:thead) {
        header_rows.each do |row|
          h.concat h.content_tag(:tr) {
            row.cells.each do |cell|
              h.concat h.content_tag(:th, cell.body, :colspan => cell.colspan, :rowspan => cell.rowspan)
            end
          }
        end
      }

      h.concat h.content_tag(:tbody) {
        body_rows.each do |row|
          h.concat h.content_tag(:tr) {
            row.cells.each do |cell|
              h.concat h.content_tag(:td, cell.body, colspan: cell.colspan)
            end
          }
        end
      }
    }
  end

  def captions
    @captions ||= HtmlCompilator::Tables::Caption.generate(:table => self)
  end

  def header_rows
    HtmlCompilator::Tables::HeaderRow.generate(:table => self, :node => node.xpath('BOXHD'))
  end

  def body_rows
    @body_rows ||= node.css('ROW').map do |row_node|
      HtmlCompilator::Tables::BodyRow.new(:table => self, :node => row_node)
    end
  end

  def num_columns
    node.attr("COLS").to_i
  end

  def h
    @h ||= ActionView::Base.new
  end

  def transform(xml)
    @text_transformer ||= Nokogiri::XSLT(
      File.read("#{Rails.root}/app/views/xslt/matchers/full_text.html.xslt")
    )
    @text_transformer.transform(Nokogiri::XML(xml)).to_s.strip.html_safe
  end
end
