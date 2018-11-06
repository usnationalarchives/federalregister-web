require File.dirname(__FILE__) + '/../spec_helper'

describe PublicInspectionDocumentIssuesController do
  context "GET /public-inspection" do
    it "redirects to /public-inspection/current" do
      expect(get :public_inspection).to redirect_to(
        current_public_inspection_issue_path
      )
    end
  end
end
