require File.dirname(__FILE__) + '/../spec_helper'

describe TableOfContentsPresenter do
  before(:each) do
    TableOfContentsPresenter.
      any_instance.
      stub(:retrieve_toc_data).
      and_return(
        JSON.parse(
          File.read(
            File.join(Rails.root, 'spec', 'fixtures', '2016-02-29-document-toc.json')
          )
        )
      )
  end

  let(:date) { Date.parse('2016-02-29') }

  let(:filter_to_documents) {
    get_documents ["2016-04047", "2016-03956", "2016-04244"]
  }

  let(:presenter) { TableOfContentsPresenter.new(date) }
  let(:presenter_with_filter) {
    TableOfContentsPresenter.new(date, filter_to_documents)
  }

  context "#document_numbers" do
    it "returns an array of all document numbers", :vcr do
      expect(
        presenter.document_numbers.size
      ).to eq(122)
    end

    it "returns an array of filtered document numbers when documents are passed", :vcr do
      expect(
        presenter_with_filter.document_numbers.size
      ).to eq(3)

      expect(
        presenter_with_filter.document_numbers.sort
      ).to eq(["2016-03956", "2016-04047", "2016-04244"])
    end
  end

  context "#agencies" do
    it "#returns all agencies", :vcr do
      expect(
        presenter.agencies.size
      ).to eq(66)
    end

    context "filtered a single document number" do
      let(:filter_to_documents) { get_documents ["2016-04323"] }
      let(:presenter_with_filter) {
        TableOfContentsPresenter.new(date, filter_to_documents)
      }

      it "returns a single agency with a single document", :vcr do
        expect(
          presenter_with_filter.agencies.size
        ).to eq(1)

        agency = presenter_with_filter.agencies['education-department']
        expect(
          inspect_documents(agency)
        ).to eq(["2016-04323"])
      end
    end

    context "filtered to multiple document numbers" do
      context "from a single agency" do
        let(:filter_to_documents) { get_documents ["2016-04323", "2016-04338"] }
        let(:presenter_with_filter) {
          TableOfContentsPresenter.new(date, filter_to_documents)
        }

        it "#agencies returns a single agency with a multiple documents", :vcr do
          expect(
            presenter_with_filter.agencies.size
          ).to eq(1)

          agency = presenter_with_filter.agencies['education-department']
          expect(
            inspect_documents(agency)
          ).to eq(["2016-04323", "2016-04338"])
        end
      end

      context "from a multiple agencies" do
        let(:filter_to_documents) {
          get_documents ["2016-04323", "2016-04245", "2016-04080"]
        }

        let(:presenter_with_filter) {
          TableOfContentsPresenter.new(date, filter_to_documents)
        }

        it "#agencies returns multiple agencies with appropriate documents", :vcr do
          expect(
            presenter_with_filter.agencies.size
          ).to eq(2)

          agency = presenter_with_filter.agencies['education-department']
          expect(
            inspect_documents(agency)
          ).to eq(["2016-04323"])

          agency2 = presenter_with_filter.agencies['environmental-protection-agency']
          expect(
            inspect_documents(agency2)
          ).to eq(["2016-04245", "2016-04080"])
        end
      end
    end
  end

  it "#filtered_agency_slugs returns an array of uniq agency slugs", :vcr do
    expect(
      presenter_with_filter.filtered_agency_slugs
    ).to eq(["agricultural-marketing-service", "coast-guard"])
  end

  context "see also agencies," do
    context "and see also agency has no documents," do
      let(:documents) {
        Document.find_all(
          ["2016-04047"],
          fields: [:document_number, :agencies]
        ).results
      }

      it "#agencies returns the agency with the see also filtered to the correct agencies", :vcr do
        presenter = TableOfContentsPresenter.new(date, documents)

        expect(
          presenter.agencies.size
        ).to eq(2)

        agency = presenter.agencies['agricultural-marketing-service']
        expect(
          inspect_documents(agency)
        ).to eq(["2016-04047"])


        agency2 = presenter.agencies['agriculture-department']
        expect(
          agency2.see_also
        ).to eq(
          [
            {
              "name" => "Agricultural Marketing Service",
              "slug" => "agricultural-marketing-service"
            }
          ]
        )
      end
    end

    context "and see also agency has documents," do
      let(:documents) {
        Document.find_all(
          ["2016-04328", "2016-04305", "2016-04215"],
          fields: [:document_number, :agencies]
        ).results
      }

      it "#agencies returns the agency with the see also filtered to the correct agencies", :vcr do
        presenter = TableOfContentsPresenter.new(date, documents)

        expect(
          presenter.agencies.size
        ).to eq(3)

        agency = presenter.agencies['air-force-department']
        expect(
          inspect_documents(agency)
        ).to eq(["2016-04305"])


        agency2 = presenter.agencies['defense-department']
        expect(
          agency2.see_also
        ).to eq(
          [
            {
              "name" => "Air Force Department",
              "slug" => "air-force-department"
            },
            {
              "name" => "Engineers Corps",
              "slug" => "engineers-corps"
            }
          ]
        )

        expect(
          inspect_documents(agency2)
        ).to eq(["2016-04328"])


        agency3 = presenter.agencies['engineers-corps']
        expect(
          inspect_documents(agency3)
        ).to eq(["2016-04215"])
      end
    end
  end

  def get_documents(document_numbers)
    Document.find_all(
      document_numbers,
      fields: [:document_number, :agencies]
    ).results
  end

  def inspect_documents(agency_hash)
    agency_hash.document_categories.map do |cat|
      cat["documents"].map{|d| d["document_numbers"]}
    end.flatten
  end
 end
