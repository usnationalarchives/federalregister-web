# encoding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe "ListOfSubjectsTopicParser" do
  context "it returns a proper list of topics" do
    it "when topic string is a simple comma seperated list (and removes the trailing period)" do
      topic_string = "Aged, Community development block grants, Grant programs—housing and community development, Reporting and recordkeeping requirements."

      expect(
        ListOfSubjectsTopicParser.parse(topic_string)
      ).to eq(
        ["Aged", "Community development block grants", "Grant programs—housing and community development", "Reporting and recordkeeping requirements"]
      )
    end

    it "when the topic string contains commas in the individual topic" do
      topic_string = "Administrative practice and procedure, Banks, banking, Brokers, Terrorism."

      expect(
        ListOfSubjectsTopicParser.parse(topic_string)
      ).to eq(
        ["Administrative practice and procedure", "Banks, banking", "Brokers", "Terrorism"]
      )
    end

    it "when the topic string contains multiple capitalized words in a single item" do
      topic_string = "Authority delegations (Government agencies), Children, Commodity School Program, Food assistance programs, National School Lunch Program."

      expect(
        ListOfSubjectsTopicParser.parse(topic_string)
      ).to eq(
        ["Authority delegations (Government agencies)", "Children", "Commodity School Program", "Food assistance programs", "National School Lunch Program"]
      )
    end

    context "when the topic is a special case" do
      it "returns the proper topic for 'Guantanamo Bay Naval Station, Cuba'" do
        topic_string = "Alcohol and alcoholic beverages, Guantanamo Bay Naval Station, Cuba, Trade agreements."

        expect(
          ListOfSubjectsTopicParser.parse(topic_string)
        ).to eq(
          ["Alcohol and alcoholic beverages", "Guantanamo Bay Naval Station, Cuba", "Trade agreements"]
        )
      end
    end
  end
end
