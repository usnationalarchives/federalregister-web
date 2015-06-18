class SparklinePresenter
  include ActionView::Helpers::TagHelper

  attr_reader :height, :period, :title, :width

  def initialize(search_conditions, args={})
    @period = args.fetch(:period).to_s.capitalize
    @title = args.fetch(:title)
    @width = args.fetch(:width){ 135 }
    @height = args.fetch(:height) { 25 }
  end

  def image_tag
    tag(
      :img,
      src: image_url, alt: image_alt, width: width, height: height
    )
  end

  private

  def image_alt
    "Sparkline of #{period} Document Distribution"
  end

  def image_url
    "FederalRegister::Facet::Document::#{period}".
      constantize.
      chart_url
  end
end
