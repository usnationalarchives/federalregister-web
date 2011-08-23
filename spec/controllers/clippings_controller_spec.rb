require File.dirname(__FILE__) + '/../spec_helper'

describe ClippingsController do
  describe '#index' do
    it "preloads article data" do
      Clipping.should_receive(:with_preloaded_articles).once
      get :index
    end
  end
end
