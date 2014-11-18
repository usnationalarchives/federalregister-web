namespace :regulations_dot_gov do
  task :warm_comment_form_cache => :environment do
    RegulationsDotGov::CommentFormCacheWarmer.new.perform
  end

  task :notify_comment_publication => :environment do
    RegulationsDotGov::CommentPublicationNotifier.new.perform
  end
end
