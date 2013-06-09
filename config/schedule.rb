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

set :output, {:error => '/home/tomlein/cron-error.log', :standard => '/home/tomlein/cron.log'}

every 1.minutes do
  runner "PlannedUpdate.download_planned_updates"
end

every 1.minutes do
  runner "UnprocessedCache.process_planned_caches"
end

every 1.minutes do
  runner "PageRanking.update_rankings"
end

every 1.hours do
  runner "Page.update_tracked_websites"
end

# Learn more: http://github.com/javan/whenever
