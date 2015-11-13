require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::Docket, :reg_gov do
  before(:all) do
    $response_keys = Array.new
  end

  let(:client) { double(:client) }

  describe "#title" do
    it "returns the docket title" do
      docket_title = "Notice of Request"
      docket = RegulationsDotGov::Docket.new(client,
                                             track_response_keys({'title' => docket_title}))

      expect( docket.title ).to eq(docket_title)
    end
  end

  describe "#docket_id" do
    it "returns the docket id when present" do
      docket_id = "APHIS-2013-0071"
      docket = RegulationsDotGov::Docket.new(client,
                                             track_response_keys({'docketId' => docket_id}))

      expect( docket.docket_id ).to eq(docket_id)
    end
  end

  describe "#regulation_id_number" do
    it "returns the regulation id number when present" do
      rin = "0648-BD10"
      docket = RegulationsDotGov::Docket.new(client,
                                             track_response_keys({'rin' => rin}))

      expect( docket.regulation_id_number ).to eq(rin)
    end

    it "returns nil when the regulation id number is blank" do
      rin = ""
      docket = RegulationsDotGov::Docket.new(client,
                                            track_response_keys({'rin' => rin}))

      expect( docket.regulation_id_number ).to eq(nil)
    end

    it "returns nil when the regulation id number is 'Not Assigned'" do
      rin = "Not Assigned"
      docket = RegulationsDotGov::Docket.new(client,
                                             track_response_keys({'rin' => rin}))

      expect( docket.regulation_id_number ).to eq(nil)
    end
  end

  describe "#supporting_documents" do
    let(:docket_id) { "EPA-HQ-SFUND-2005-0011" }
    let(:docket)    { RegulationsDotGov::Docket.new(client,
                                                    track_response_keys({'docketId' => docket_id})) }

    it "is called with the proper arguments" do
      client.stub(:find_documents)

      client.should_receive(:find_documents).with(:dktid => docket_id, :dct => "SR", :so => "DESC", :sb => "docId")

      docket.supporting_documents
    end
  end

  context "associated documents" do
    let(:docket_id) { docket_id = "APHIS-2013-0071" }
    let(:docket)    { RegulationsDotGov::Docket.new(client,
                                                    track_response_keys({'docketId' => docket_id})) }

    describe "#supporting_documents" do
      it "is called with the proper arguments" do
        client.stub(:find_documents)

        client.should_receive(:find_documents).with(:dktid => docket_id, :dct => "SR", :so => "DESC", :sb => "docId")

        docket.supporting_documents
      end
    end

    describe "#supporting_documents_count" do
      it "is called with the proper arguments" do
        client.stub(:count_documents)

        client.should_receive(:count_documents).with(:dktid => docket_id, :dct => "SR")

        docket.supporting_documents_count
      end
    end

    describe "#comments_count" do
      it "is called with the proper arguments" do
        client.stub(:count_documents)

        client.should_receive(:count_documents).with(:dktid => docket_id, :dct => "PS")

        docket.comments_count
      end
    end
  end

  context "verify keys" do
    let(:client) { RegulationsDotGov::Client.new() }

    before (:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v3/')
    end

    after(:each) do
      RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v3/')
    end

    it "ensures all keys used in tests above actually exist in the api response", :vcr do
      docket_id = 'CFPB_FRDOC_0001'
      docket = client.find_docket(docket_id)

      $response_keys.each do |keys|
        keys.each do |arr|
          expect( docket.raw_attributes.seek *arr ).to_not be(nil), "expected api response to contain #{arr}, but did not find it."
        end
      end
    end
  end
end
