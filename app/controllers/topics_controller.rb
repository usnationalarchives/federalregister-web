class TopicsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    cache_for 1.day

    @topics = TopicFacet.search.sort{|a, b| a.name <=> b.name}
  end

  def show
    cache_for 1.day
    @presenter = TopicPresenter.new(params[:id])

    respond_to do |wants|
      wants.html
      wants.rss {
        redirect_to "#{Settings.services.fr.web.base_url}/documents/search.rss?conditions[topics][]=#{@presenter.topic.slug}",
          status: :moved_permanently
      }
    end
  rescue TopicPresenter::InvalidTopic
    raise ActiveRecord::RecordNotFound
  end

  def suggestions
    topics = Topic.suggestions(params[:term])
    render :json => topics.map{|t|
      {name: t.name, slug: t.slug, url: t.url}
    }
  end

  def significant_entries
    cache_for 1.day
    @presenter = TopicPresenter.new(params[:id])

    respond_to do |wants|
      wants.rss do
        redirect_to "#{Settings.services.fr.web.base_url}/documents/search.rss?conditions[topics][]=#{@presenter.topic.slug}&conditions[significant]=1",
          status: :moved_permanently
      end
    end
  end
end
