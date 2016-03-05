require File.dirname(__FILE__) + '/../spec_helper'

describe TableOfContentsPresenter do
  let(:date) { Date.parse('2016-02-29') }

  let(:documents) {
    Document.find_all(
      ["2016-04047", "2016-03956", "2016-04244"],
      fields: [:document_number, :agencies]
    ).results
  }

  it "#filter_to_document_numbers returns an array of document numbers", :vcr do
    presenter = TableOfContentsPresenter.new(date, documents)

    expect(
      presenter.filter_to_document_numbers.sort
    ).to eq(["2016-03956", "2016-04047", "2016-04244"])
  end

  it "#filter_to_agency_slugs returns an array of uniq agency slugs", :vcr do
    presenter = TableOfContentsPresenter.new(date, documents)

    expect(
      presenter.filter_to_agency_slugs
    ).to eq(["agricultural-marketing-service", "coast-guard"])
  end

  context "filtering documents for mailing lists" do
    before :each do
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

    context "with a single document number" do
      let(:documents) {
        Document.find_all(
          ["2016-04323"],
          fields: [:document_number, :agencies]
        ).results
      }

      it "#filtered_agencies returns a single agency with a single document" do
        presenter = TableOfContentsPresenter.new(date, documents)

        expect(
          presenter.filtered_agencies.size
        ).to eq(1)

        name, agency = presenter.filtered_agencies.first.first

        expect(name).to eq('education-department')
        expect(
          retrieve_documents(agency)
        ).to eq(["2016-04323"])
      end
    end

    context "with a multiple document numbers" do
      context "from a single agency" do
        let(:documents) {
          Document.find_all(
            ["2016-04323", "2016-04338"],
            fields: [:document_number, :agencies]
          ).results
        }

        it "#filtered_agencies returns a single agency with a multiple documents" do
          presenter = TableOfContentsPresenter.new(date, documents)

          expect(
            presenter.filtered_agencies.size
          ).to eq(1)

          name, agency = presenter.filtered_agencies.first.first

          expect(name).to eq('education-department')
          expect(
            retrieve_documents(agency)
          ).to eq(["2016-04323", "2016-04338"])
        end
      end

      context "from a multiple agencies" do
        let(:documents) {
          Document.find_all(
            ["2016-04323", "2016-04245", "2016-04080"],
            fields: [:document_number, :agencies]
          ).results
        }

        it "#filtered_agencies returns a multiple agencies with appropriate documents" do
          presenter = TableOfContentsPresenter.new(date, documents)

          expect(
            presenter.filtered_agencies.size
          ).to eq(2)

          name, agency = presenter.filtered_agencies.first.first

          expect(name).to eq('education-department')
          expect(
            retrieve_documents(agency)
          ).to eq(["2016-04323"])

          name2, agency2 = presenter.filtered_agencies.last.first

          expect(name2).to eq('environmental-protection-agency')
          expect(
            retrieve_documents(agency2)
          ).to eq(["2016-04245", "2016-04080"])
        end
      end
    end

    context "see also agencies," do
      context "and see also agency has no documents," do
        let(:documents) {
          Document.find_all(
            ["2016-04047"],
            fields: [:document_number, :agencies]
          ).results
        }

        it "returns the agency with the see also filtered to the correct agencies" do
          presenter = TableOfContentsPresenter.new(date, documents)

          expect(
            presenter.filtered_agencies.size
          ).to eq(2)

          name, agency = presenter.filtered_agencies.first.first

          expect(name).to eq('agricultural-marketing-service')
          expect(
            retrieve_documents(agency)
          ).to eq(["2016-04047"])


          name2, agency2 = presenter.filtered_agencies.last.first

          expect(name2).to eq('agriculture-department')

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

        it "returns the agency with the see also filtered to the correct agencies" do
          presenter = TableOfContentsPresenter.new(date, documents)

          expect(
            presenter.filtered_agencies.size
          ).to eq(3)

          name, agency = presenter.filtered_agencies[0].first

          expect(name).to eq('air-force-department')
          expect(
            retrieve_documents(agency)
          ).to eq(["2016-04305"])


          name2, agency2 = presenter.filtered_agencies[1].first

          expect(name2).to eq('defense-department')

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
            retrieve_documents(agency2)
          ).to eq(["2016-04328"])

          name3, agency3 = presenter.filtered_agencies[2].first

          expect(name3).to eq('engineers-corps')
          expect(
            retrieve_documents(agency3)
          ).to eq(["2016-04215"])
        end
      end
    end

    def retrieve_documents(agency_hash)
      agency_hash.document_categories.map do |cat|
        cat["documents"].map{|d| d["document_numbers"]}
      end.flatten
    end
  end
 end
