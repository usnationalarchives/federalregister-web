class ApplicationPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  # include RouteBuilder::Application
end
