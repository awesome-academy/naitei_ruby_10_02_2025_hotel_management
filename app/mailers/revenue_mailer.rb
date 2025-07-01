class RevenueMailer < ApplicationMailer
  def daily_revenue_report admin_email, total_revenue, month, year, bill_count
    @total_revenue = total_revenue
    @month = month
    @year = year
    @bill_count = bill_count
    mail(to: admin_email,
         subject: t("revenue_report.subject", month: @month, year: @year))
  end
end
