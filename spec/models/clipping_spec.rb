#require File.dirname(__FILE__) + '/../spec_helper'

#describe Clipping do
  #it { should validate_presence_of(:document_number) }

  #describe '#article' do
    #context "when document_number is nil" do
      #it "is nil" do
        #Clipping.new.article.should be_nil
      #end
    #end

    #context "when document_number is present" do
      #it "loads the article via the FR2 API" do
        #FederalRegister::Document.should_receive(:find).with('abc-123').and_return(:x)
        #clipping = Clipping.new(:document_number => "abc-123")
        #clipping.article.should == :x
      #end

      #it "caches the result locally" do
        #FederalRegister::Document.should_receive(:find).with('abc-123').once.and_return(:x)
        #clipping = Clipping.new(:document_number => "abc-123")
        #clipping.article
        #clipping.article
      #end
    #end
  #end

  #describe '.with_preloaded_articles' do
    #it 'fetches multiple articles at once' do
      #clipping_1 = FactoryGirl.create(:clipping)
      #clipping_2 = FactoryGirl.create(:clipping)
      #FederalRegister::Document.should_receive(:find_all).with([clipping_1.document_number, clipping_2.document_number]).and_return([])
      #clippings = Clipping.with_preloaded_articles
      #clippings.should have(2).items
    #end

    #it 'is chainable' do
      #clipping_1 = FactoryGirl.create(:clipping, :document_number => "XXXX-1200")
      #clipping_2 = FactoryGirl.create(:clipping, :document_number => "2011-1234")
      #FederalRegister::Document.should_receive(:find_all).with([clipping_1.document_number]).and_return([])
      #clippings = Clipping.where("document_number like 'XXXX-%'").with_preloaded_articles
      #clippings.should have(1).item
    #end
  #end

  #describe "#all_preloaded_from_cookie" do
    #it "returns clippings with articles" do
      ## clipping_1 = FactoryGirl.create(:clipping, :document_number => "2011-1234")
      ## clipping_2 = FactoryGirl.create(:clipping, :document_number => "2011-9876")

      #@clippings = Clipping.all_preloaded_from_cookie({"2011-1234" => [0], "2011-9876" => [0]})
      #@clippings.size.should eql(2)
      #@clippings.first.article.should_not be(nil)
      #@clippings.first.article.type.should eql("Notice")
      #@clippings.first.article.publication_date.should eql(Date.parse('Mon, 25 Apr 2011'))
    #end
  #end

#end
