# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :rake, [
  'cd :path',
  'source /etc/container_environment.sh',
  'rake :task --trace :output',
].join(' && ')

set :output, lambda { "2>&1 | sed \"s/^/[$(date)] /\" >> #{path}/log/#{log}.log" }

every 1.day, at: '6PM' do
  set :log, 'regulations_dot_gov_comments_posted'
  rake 'regulations_dot_gov:notify_comment_publication'
end

every 1.day, at: '12:01 am' do
  rake 'monthly:stats:persist_daily_redis_stats_to_disk'
end

