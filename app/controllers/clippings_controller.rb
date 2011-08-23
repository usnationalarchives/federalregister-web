class ClippingsController < ApplicationController
  def index
    @clippings = Clipping.with_preloaded_articles
  end
end
