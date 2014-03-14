require File.dirname(__FILE__) + '/../spec_helper'

describe "reader aids routes" do
  it "reader-aids routes to ReaderAids#index" do
    expect(get: "reader-aids").to route_to(
      controller: "reader_aids",
      action: "index",
    )

    expect(get: reader_aids_path).to route_to(
      controller: "reader_aids",
      action: "index",
    )
  end
end
