require 'spec_helper'

describe SessionsController do
  let(:session_user_details) {
    OmniAuth::AuthHash.new(
      email:           stubbed_auth_hash["extra"]["raw_info"]["email"],
      email_confirmed: stubbed_auth_hash["extra"]["raw_info"]["email_confirmed"],
      token:           stubbed_auth_hash["credentials"]["token"],
      id:              stubbed_auth_hash["uid"]
    )
  }

  context "#create" do
    it "Creates the user session properly" do
      request.env["omniauth.auth"] = stubbed_auth_hash

      get :create, params: {provider: 'ofr'}

      # Sets cookie JS and varnish relies upon
      expect(cookies["expect_signed_in"]).to eq "1"

      # Sets the correct values in the user session
      expect(session[:user_details]).to eq(session_user_details)
    end
  end

  context "#destroy" do
    before(:each) do
      session[:user_details]      = session_user_details
      cookies["expect_signed_in"] = "1"
    end

    it "AJAX requests delete the session and remove the signed in cookie" do
      get :destroy, params: {ajax_request: true}

      expect(session.empty?).to be(true)
      expect(cookies["expect_signed_in"]).to eq "0"
    end

    it "Non-AJAX requests do not delete the session or remove the cookie, but only redirect to FR Profile" do
      get :destroy

      expect(session[:user_details]).to eq(session_user_details)
      expect(cookies["expect_signed_in"]).to eq "1"
    end

  end

end
