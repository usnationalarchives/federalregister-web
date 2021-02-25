require 'spec_helper'

describe 'when a user transitions from not_logged_in' do
  before do
  end

  describe "comment creation" do

    it "creates a comment with the correct attributes" do
      request_params = {
        "reg_gov_response_data": {
            "id": "klb-dy99-pl2c",
            "type": "comments",
            "attributes": {
                "zip":                 nil,
                "country":             nil,
                "lastName":            "Anonymous",
                "city":                nil,
                "receiveDate":         "2021-02-18T21:37:52.238+0000",
                "submissionKey":       nil,
                "submitterRep":        nil,
                "userId":              "b3bda779-8165-4c17-ad31-f3389d77af3c",
                "organizationType":    nil,
                "firstName":           "Anonymous",
                "submissionType":      "API",
                "submitterType":       "ANONYMOUS",
                "commentOnDocumentId": "CPSC-2013-0025-0004",
                "stateProvinceRegion": nil,
                "phone":               nil,
                "organization":        nil,
                "sendEmailReceipt":    false,
                "numItemsReceived":    0,
                "files":               nil,
                "comment":             "test comment",
                "category":            nil,
                "email":               nil
            }
        }
      }

      post comment_path('2021-03790'), params: request_params

      expect(Comment.count).to eq(1)
      comment = Comment.first
      expect(comment).to have_attributes(
        document_number: '2021-03790',
        comment_tracking_number: 'klb-dy99-pl2c',
        comment_document_number: 'CPSC-2013-0025-0004',
        agency_name: 'Consumer Product Safety Commission',
        agency_participating: true
      )
    end

    it "doesn't error/badgers if the agency is not found"
    it "records reg.gov subscription status"
  end
end

