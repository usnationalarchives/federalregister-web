require File.dirname(__FILE__) + '/../spec_helper'

describe Search::PublicInspection do
  context "#valid_search? with invalid conditions" do
    it "returns false for :near" do
      search = Search::PublicInspection.new(conditions: {near: {location: '94109', within: 25}})

      expect(search.valid_search?).to eq(false)
    end

    it "returns false for :cfr" do
      search = Search::PublicInspection.new(conditions: {cfr: {part: 49, title: 24}})

      expect(search.valid_search?).to eq(false)
    end
  end

  context "#invalid_conditions" do
    it "returns the proper invalid_conditions when given all conditions" do
      invalid_conditions = Search::PublicInspection.
        new(conditions: stubbed_conditions).
        invalid_conditions

      [
        :cfr,
        :citing_document_numbers,
        :comment_date,
        :correction,
        :effective_date,
        :near,
        :president,
        :presidential_document_type,
        :presidential_document_type_id,
        :publication_date,
        :regulation_id_number,
        :section_ids,
        :sections,
        :significant,
        :small_entity_ids,
        :topics,
        :topic_ids
      ].each do |condition|
        expect(invalid_conditions.include?(condition)).to eq(true),
          "expected invalid_conditions to contain #{condition} but it did not"
      end
    end
  end
end
