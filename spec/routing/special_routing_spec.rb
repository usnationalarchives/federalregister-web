require File.dirname(__FILE__) + '/../spec_helper'

describe "special routes" do
  it "/special/header/type routes to special#header" do
    expect(get: "/special/header/official").to route_to(
      controller: "special",
      action: "header",
      type: 'official'
    )

    expect(get: "/special/header/public-inspection").to route_to(
      controller: "special",
      action: "header",
      type: 'public-inspection'
    )

    expect(get: "/special/header/reader-aids").to route_to(
      controller: "special",
      action: "header",
      type: 'reader-aids'
    )

    expect(get: "/special/header/failed-constraint").not_to route_to(
      controller: "special",
      action: "header",
      type: 'failed-constraint'
    )
  end

  it "/ routes to special#home" do
    expect(get: "/").to route_to(
      controller: "special",
      action: "home"
    )

    expect(root_path).to eq('/')
  end
end
