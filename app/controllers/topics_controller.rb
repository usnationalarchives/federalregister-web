class TopicsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @presenter = TopicPresenter.new(params[:id])
  end

  def show
    @presenter = TopicPresenter.new(params[:id])
    if @presenter.invalid_topic?
      raise ActiveRecord::RecordNotFound
    else
      respond_to do |wants|
        wants.html
        wants.rss do
          redirect_to "https://www.federalregister.gov/articles/search.rss?conditions[topics][]=#{@presenter.topic.slug}",
            status: :moved_permanently
        end
      end
    end
  end

  def significant_entries
    cache_for 1.day
    @presenter = TopicPresenter.new(params[:id])

    respond_to do |wants|
      wants.rss do
        redirect_to "https://www.federalregister.gov/articles/search.rss?conditions[topics][]=#{@presenter.topic.slug}&conditions[significant]=1",
          status: :moved_permanently
      end
    end
  end
end
