require File.dirname(__FILE__) + '/../spec_helper'

describe EmailHighlight do

  it "has valid email highlight definitions" do
    EmailHighlight::HIGHLIGHTS.each do |definition|
      expect( EmailHighlight.valid_definition?(definition) ).to eq(true), "expected valid defintion for #{definition.inspect}, instead got invalid definition"
    end
  end

  describe ".highlights" do
    it "returns an array of active highlights" do
      highlights = EmailHighlight.highlights

      expect( highlights ).to be_kind_of(Array)
      expect( highlights ).to have(5).items
    end
  end

  describe ".rotatable_highlights" do
    it "returns an array of highlights" do
      rotatable_highlights = EmailHighlight.rotatable_highlights

      expect( rotatable_highlights ).to be_kind_of(Array)
      expect( rotatable_highlights ).to have(4).items
    end
  end

  describe ".find" do
    let(:awesome_highlight) { FactoryGirl.build(:email_highlight, :name => "awesome_feature") }

    before(:each) do 
      EmailHighlight.stub(:highlights).and_return( [awesome_highlight] )
    end

    it "returns the requested highlight when it exists" do
      expect( EmailHighlight.find(awesome_highlight.name) ).to be(awesome_highlight)
    end

    it "returns nil when the requested highlight does not exist" do
      expect( EmailHighlight.find('not_so_awesome_feature') ).to be(nil)
    end

    context "disabled highlight" do
      before(:each) do
        awesome_highlight.enabled = false
      end

      it "should return nil for a disabled highlight unless proper option is passed" do
        expect( EmailHighlight.find(awesome_highlight.name) ).to be(nil)
      end
      
      it "should return nil for a disabled highlight unless proper option is passed" do
        expect( EmailHighlight.find(awesome_highlight.name, :disabled => true) ).to be(awesome_highlight)
      end
    end
  end

  describe ".selected_highlight" do
    let(:awesome_highlight) { FactoryGirl.build(:email_highlight, :name => "awesome_feature") }

    before(:each) do
      EmailHighlight.stub(:highlights).and_return( [awesome_highlight] )
    end

    it "returns the requested highlight (by name) when highlight is in rotation" do
      expect( EmailHighlight.selected_highlight(awesome_highlight.name) ).to eq(awesome_highlight)
    end

    it "returns the requested highlight (by name) when highlight is not in rotation" do
      awesome_highlight.in_rotation = false
      expect( EmailHighlight.selected_highlight(awesome_highlight.name) ).to eq(awesome_highlight)
    end

    it "raises an exception message when the highlight is disabled" do
      awesome_highlight.enabled = false
      error_message = "Attempt to use missing or disabled highlight '#{awesome_highlight.name}' as selected highlight"

      expect{
        EmailHighlight.selected_highlight(awesome_highlight.name)
      }.to raise_exception(
        EmailHighlight::EmailHighlightError,
        error_message
      )
    end
  end

  describe ".calculate_weight_hash" do
    let(:awesome_highlight) { FactoryGirl.build(:email_highlight, :name => "awesome_feature", :priority => 2) }
    let(:so_so_highlight) { FactoryGirl.build(:email_highlight, :name => "so_so_feature") }
    let(:old_highlight) { FactoryGirl.build(:email_highlight, :name => "old_feature", :in_rotation => false) }

    before(:each) do
      EmailHighlight.stub(:rotatable_highlights).and_return( [awesome_highlight, so_so_highlight] )
    end

    it "creates a weight hash for rotatable highlights" do
      weight_hash = EmailHighlight.calculate_weight_hash

      expect( weight_hash[awesome_highlight.name] ).to eq(2)
      expect( weight_hash[so_so_highlight.name] ).to eq(1)
      expect( weight_hash[old_highlight.name] ).to be_empty #in_rotation => false
    end
  end

  describe ".pick" do
    let(:awesome_highlight) { FactoryGirl.build(:email_highlight, :name => "awesome_feature") }
    let(:so_so_highlight) { FactoryGirl.build(:email_highlight, :name => "so_so_feature") }
    let(:old_highlight) { FactoryGirl.build(:email_highlight, :name => "old_feature") }

    before(:each) do
      EmailHighlight.stub(:rotatable_highlights).and_return( [awesome_highlight, so_so_highlight, old_highlight] )
    end

    it "returns an array of items" do
      expect( EmailHighlight.pick(1) ).to be_kind_of(Array)
    end

    it "returns the (unique) number of items requested" do
      highlights = EmailHighlight.pick(3)
      expect( highlights ).to have(3).items
      expect( highlights[0] ).not_to eq(highlights[1])
      expect( highlights[1] ).not_to eq(highlights[2])
      expect( highlights[2] ).not_to eq(highlights[0])
    end

    it "takes an exclude option and excludes that item" do
      # it's possible to get lucky and not happen to pick the one you're 
      # attempting to exclude on any given single run, so 10 times!
      10.times do
        highlights = EmailHighlight.pick(2, :exclude => [old_highlight])

        expect( highlights ).to include(awesome_highlight)
        expect( highlights ).to include(so_so_highlight)
        expect( highlights ).to_not include(old_highlight)
      end
    end
  end

  describe ".highlights_with_selected" do
    let(:awesome_highlight) { FactoryGirl.build(:email_highlight, :name => "awesome_feature") }
    let(:so_so_highlight) { FactoryGirl.build(:email_highlight, :name => "so_so_feature") }
    let(:old_highlight) { FactoryGirl.build(:email_highlight, :name => "old_feature") }

    before(:each) do
      EmailHighlight.stub(:highlights).and_return( [awesome_highlight, so_so_highlight, old_highlight] )
      EmailHighlight.stub(:rotatable_highlights).and_return( [awesome_highlight, so_so_highlight, old_highlight] )
    end

    it "returns the selected highlight" do
      expect( 
        EmailHighlight.highlights_with_selected(1, awesome_highlight.name)
      ).to include(awesome_highlight)
    end

    it "returns the number of additional highlights requested (in addition to the selected highlight)" do
      expect(
        EmailHighlight.highlights_with_selected(1, awesome_highlight.name)
      ).to have(2).items

      expect(
        EmailHighlight.highlights_with_selected(2, awesome_highlight.name)
      ).to have(3).items
    end
  end
end
