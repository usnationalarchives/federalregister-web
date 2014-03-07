require File.dirname(__FILE__) + '/../spec_helper'

describe PublicInspectionDocumentsController do
  context "GET /public-inspection" do
    it "redirects to /public-inspection/current" do
      expect{
        get :public_inspection
      }.to redirect_to('/public-inspection/current')
    end
  end
end

