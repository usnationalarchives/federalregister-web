require File.dirname(__FILE__) + '/../spec_helper'

  describe 'when a user transitions from not_logged_in' do
    before do
      @document_number = "2011-12345"
      @user = Factory.create(:user)
    end

    describe "to logged_in" do

      it "should save all documents in the users session" do
        raise (post(clippings_url, :entry => {:document_number => @document_number})).inspect
        raise cookies[:document_numbers].inspect
        post user_session_path, :email => @user.email, :password => @user.password


        Clipping.count.should eql(1)
      end
    end
  end

