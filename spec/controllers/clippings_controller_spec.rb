#require File.dirname(__FILE__) + '/../spec_helper'

#describe ClippingsController do
  ## describe '#index' do
  ##   it "preloads article data" do
  ##     Clipping.should_receive(:with_preloaded_articles).once
  ##     get :index
  ##   end
  ## end

  #describe '#create' do
    
    #describe 'without user logged in' do
      #before do
        #session[:document_numbers] = nil
        #@document_number = "2011-12345"
        #@default_folder = [0] # the clipboard
      #end

      #it "adds the document to a cookie if there is no document numbers in the cookie" do
        #post :create, :entry => {:document_number => @document_number}
        #cookies[:document_numbers].should eql( {@document_number => @default_folder}.to_json )
      #end

      #it "adds the document to the cookie is there are already document numbers in the cookie" do
        #post :create, :entry => {:document_number => "2011-98765"}

        #post :create, :entry => {:document_number => @document_number}
        #cookies[:document_numbers].should eql( {"2011-98765" => @default_folder, @document_number => @default_folder}.to_json )
      #end
    #end

    #describe 'with user logged in' do
      #login_user

      #before do 
        #@document_number = "2011-12345"
      #end

      #it "should have a current_user" do
        #subject.current_user.should_not be_nil
      #end

      #it "creates a new clipping when a document has not already been clipped" do
        #lambda {
          #post :create, :entry => {:document_number => @document_number}
        #}.should change(Clipping, :count).by(1)
      #end

      #it "does not create a new clipping when a document has already been clipped" do
        #post :create, :entry => {:document_number => @document_number}
        #lambda {
          #post :create, :entry => {:document_number => @document_number}
        #}.should_not change(Clipping, :count).by(1)
      #end
    #end 
  #end
#end
