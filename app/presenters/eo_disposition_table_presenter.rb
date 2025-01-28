class EoDispositionTablePresenter < ExecutiveOrderPresenter
  def name
    "Executive Order Disposition Table"
  end

  def description
    "Disposition Tables contain information about Executive Orders beginning with those signed by #{President.first.full_name} and are arranged according to Presidential administration and year of signature.
    The tables are compiled and maintained by the Office of the Federal Register editors."
  end

  def fr_content_box_title
    "#{year} #{president.full_name} Executive Order Disposition Table"
  end

  def current_page?(president, eo_collection)
    president.identifier == self.president.identifier && eo_collection.year == year.to_i
  end
end
