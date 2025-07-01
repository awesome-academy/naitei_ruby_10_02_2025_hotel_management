class SendRevenueReportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform month = Time.zone.today.month, year = Time.zone.today.year
    bills = Bill.paid_in_month(month, year)
    total_revenue = bills.sum(:total)
    bill_count = bills.count

    admin_emails = fetch_admin_emails
    return if admin_emails.empty?

    send_report(admin_emails, total_revenue, month, year, bill_count)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_admin_emails
    User.admin_emails
  end

  def send_report emails, total_revenue, month, year, bill_count
    emails.each do |email|
      RevenueMailer
        .daily_revenue_report(email, total_revenue, month, year, bill_count)
        .deliver_later
    end
  end

  def handle_error error
    raise error
  end
end
