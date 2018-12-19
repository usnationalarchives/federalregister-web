require 'spec_helper'

describe Search::Document do
  context "#invalid_conditions" do
    it "returns the proper invalid_conditions when given all conditions" do
      invalid_conditions = Search::Document.
        new(conditions: stubbed_conditions).
        invalid_conditions

      [
        :special_filing
      ].each do |condition|
        expect(invalid_conditions.include?(condition)).to eq(true),
          "expected invalid_conditions to contain #{condition} but it did not"
        end
      end
    end
end
