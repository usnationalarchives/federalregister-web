# force honeybadger to load environment so Rails.application.secrets can be read
namespace :honeybadger do
  task :deploy => [:environment]
end
