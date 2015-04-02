require File.dirname(__FILE__) + '/../spec_helper'

describe PublicInspectionDocumentsController, :no_ci do
  context "GET /public-inspection" do
    it "redirects to /public-inspection/current" do
      #binding.pry
      expect{
        get :public_inspection
      }.to redirect_to(current_public_inspection_documents_path)
    end
  end
end

