class EoDispositionTablePresenter < ExecutiveOrderPresenter
  def name
    "Executive Order Disposition Table"
  end

  def description
    "Disposition Tables contain information about Executive Orders beginning with those signed by #{President.first.full_name} and are arranged according to Presidential administration and year of signature.
    The tables are compiled and maintained by the Office of the Federal Register editors."
  end

  def fr_content_box_type
    :reader_aid
  end

  def fr_content_box_title
    "#{year} #{president.full_name} Executive Order Disposition Table"
  end

  def fr_details_box_type
    :reader_aid_navigation
  end

  def fr_details_box_title
    "Executive Order Disposition Tables"
  end

  def current_page?(president, eo_collection)
    president == self.president && eo_collection.year == year.to_i
  end
end
