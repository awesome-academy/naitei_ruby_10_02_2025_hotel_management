module BaseAdminHelper
  def status_chip(status)
    status_classes = {
      pending: "status-chip pending",
      deposited: "status-chip deposited",
      checkined: "status-chip checkined",
      finished: "status-chip finished"
    }

    content_tag(:span, t(status.to_s), class: status_classes[status.to_sym])
  end
end
