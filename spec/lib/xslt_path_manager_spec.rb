require File.dirname(__FILE__) + '/../spec_helper'

describe XsltPathManager do
  let(:path_manager) { XsltPathManager.new('2015-01234', '2015-01-02') }

  context "initialization" do
    it "accepts a string date and converts it to a date object" do
      expect(path_manager.date).to be_a(Date)
    end

    it "accepts a date object" do
      date = Date.parse('2015-01-02')
      path_manager = XsltPathManager.new('2015-01234', date)

      expect(path_manager.date).to be_a(Date)
    end
  end

  context "documents" do
    it "#document_dir returns the proper folder path" do
      expect(
        path_manager.document_dir('full_text', 'html')
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/full_text/html/2015/01/02"
      )
    end

    it "#document_xml_path returns the proper xml file reference" do
      expect(
        path_manager.document_xml_path('table_of_contents')
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/table_of_contents/xml/2015/01/02/2015-01234.xml"
      )
    end

    it "#document_html_path returns the proper html file reference" do
      expect(
        path_manager.document_html_path('full_text')
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/full_text/html/2015/01/02/2015-01234.html"
      )
    end
  end

  context "tables" do
    it "#table_dir returns the proper table directory" do
      expect(
        path_manager.table_dir('html')
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/tables/html/2015/01/02/2015-01234"
      )
    end

    it "#table_xml_dir returns the proper table xml directory" do
      expect(
        path_manager.table_xml_dir
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/tables/xml/2015/01/02/2015-01234"
      )
    end

    it "#table_html_dir returns the proper table html directory" do
        expect(
        path_manager.table_html_dir
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/tables/html/2015/01/02/2015-01234"
      )
    end

    it "#table_xml_path returns the proper xml file reference" do
      expect(
        path_manager.table_xml_path(0)
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/tables/xml/2015/01/02/2015-01234/1.xml"
      )
    end

    it "#table_html_path returns the proper html file_reference" do
      expect(
        path_manager.table_html_path(0)
      ).to eq(
        "#{Rails.root}/../federalregister-api-core/data/documents/tables/html/2015/01/02/2015-01234/1.html"
      )
    end
  end

end
