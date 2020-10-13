require 'spec_helper'

describe PublicInspectionDocumentDecorator do

  it '#revoked_and_older_date?' do
    pi_doc = PublicInspectionDocument.new(
      'document_number'              => '2020-17392',
      'publication_date'             => nil,
      'last_public_inspection_issue' => '2020-10-05'
    )
    decorated_pi_doc = described_class.decorate(pi_doc)
    result = decorated_pi_doc.revoked_and_older_date?
    expect(result).to eq(true)
  end

end
