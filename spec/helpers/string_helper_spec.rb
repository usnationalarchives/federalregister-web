require "spec_helper"

describe "String Helpers" do

  it "#capitalize_most_words" do
    result = "u.s.-china economic and security review commission".capitalize_most_words

    expect(result).to eq('U.S.-China Economic and Security Review Commission')
  end
end
