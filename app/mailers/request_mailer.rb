class RequestMailer < ApplicationMailer
  def checkin_request request
    @request = request
    mail to: request.user.email,
         subject: t("request_mailer.checkin_request.subject")
  end

  def deny_request request
    @request = request
    mail to: request.user.email,
         subject: t("request_mailer.deny_request.subject")
  end
end
