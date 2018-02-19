require File.dirname(__FILE__) + '/../spec_helper'

# Create FakeController to test UserDataPersistor in Isolation
class FakeController < ApplicationController
  include UserDataPersistor

  def test
    persist_user_data
  end
end

describe FakeController do

  def add_arbitrary_route(route, controller_action)
    test_routes = Proc.new do
      get route => controller_action
    end
    Rails.application.routes.eval_block(test_routes)
  end

  def authenticated_session
    {
      user_details: {
        "sub"             => 9999,
        "email"           => 'john_doe@example.com',
        "email_confirmed" => true
      }
    }
  end

  describe "Clippings" do
    before(:each) do
      add_arbitrary_route('/test', "fake_controller#test")
      Clipping.any_instance.stub(:document).and_return(double)
    end

    it "persists a document if a document number is saved in the cookie" do
      cookies[:document_numbers] = [{'2014-13781' => ['my-clippings']}].to_json
      get :test, nil, authenticated_session

      clipping = Clipping.first
      {
        document_number: '2014-13781',
        user_id:         authenticated_session[:user_details]["sub"],
        folder_id:       nil
      }.each do |attribute, value|
        expect(clipping[attribute]).to eq(value)
      end
    end

  end

  describe "Comments" do

    before(:each) do
      validation_methods = [
        :send_to_regulations_dot_gov,
        :persist_comment_data,
      ]
      validation_methods.each do |validation_method|
        Comment.any_instance.stub(validation_method).and_return(true)
      end
      comment

      add_arbitrary_route('/test', "fake_controller#test")
    end

    let(:comment) do
      FactoryGirl.create(
        :comment_skipped_validations,
        comment_tracking_number: 123,
      )
    end

    it "if a comment tracking number and secret are stored in the session, and a matching comment exists in the database, the CommentMailer is called" do
      CommentMailer.stub_chain(:comment_copy, :deliver)
      CommentMailer.should_receive(:comment_copy)#.with(User.new(id: 9999, email: 'john_doe@example.com'))
      get :test, nil, authenticated_session.merge(
        comment_tracking_number: 123,
        comment_secret:          9999999999
      )
    end

    it "if a comment tracking number and secret are stored in the session, marks a subscription as confirmed if the followup_document_notification flag has been set" do
      CommentDecorator.any_instance.stub(:document).and_return(double)
      CommentMailer.stub_chain(:comment_copy, :deliver)
      get :test, nil, authenticated_session.merge(
        comment_tracking_number:        123,
        comment_secret:                 9999999999,
        followup_document_notification: "1"
      )

      expect(Subscription.first.confirmed_at).to be_truthy
    end

  end

end
