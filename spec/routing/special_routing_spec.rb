require 'spec_helper'

describe "special routes" do
  it "/ routes to special#home" do
    expect(get: "/").to route_to(
      controller: "special",
      action: "home"
    )

    expect(root_path).to eq('/')
  end
end
