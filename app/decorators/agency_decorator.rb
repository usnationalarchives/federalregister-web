class AgencyDecorator < ApplicationDecorator
  delegate_all
  attr_reader :agencies
  def initialize(agency, agencies=nil)
    super(agency)
    @agencies = agencies
  end

  def parent
    parent = agencies.
      detect{|agency| agency.id == parent_id}
    parent ? AgencyDecorator.new(parent) : nil
  end

  def children
    children = agencies.
      select{|agency| agency.parent_id == id}
    children ? children.map{|a| AgencyDecorator.new(a)} : nil
  end

  def logo_file_name
    #logic around logo file name
    logo
  end

  def logo_url(type)
    logo[type.to_s + "_url"]
  end

  def slug
    url.split('/').last
  end
end
