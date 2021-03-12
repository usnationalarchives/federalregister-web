namespace :regulations_dot_gov do

  task :notify_comment_publication => :environment do
    RegulationsDotGov::CommentPublicationNotifier.new.perform
  end
end
