set :environment, "development"
set :output, {
  standard: "log/cron.log",
  error: "log/cron_error.log"
}

report_time = ENV["REVENUE_REPORT_TIME"]

every :month, at: report_time, day: :last do
  runner "SendRevenueReportJob.perform_later(Time.zone.today.month, Time.zone.today.year)"
end
