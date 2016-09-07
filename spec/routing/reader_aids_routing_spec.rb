require File.dirname(__FILE__) + '/../spec_helper'

describe "RouteBuilder::ReaderAidUrls" do
  it "#public_inspection_learn_path returns the proper path" do
    expect(public_inspection_learn_path)
      .to eq("/reader-aids/using-federalregister-gov/understanding-public-inspection")
  end

  it "#public_inspection_table_of_effective_dates_path returns the proper path" do
    expect(public_inspection_table_of_effective_dates_path)
      .to eq("/reader-aids/using-federalregister-gov/table-of-effective-dates-time-periods")
  end
end
