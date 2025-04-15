module BaseAdminHelper
  def status_chip status
    status_classes = {
      pending: "status-chip pending",
      deposited: "status-chip deposited",
      checkined: "status-chip checkined",
      checkouted: "status-chip checkouted",
      finished: "status-chip finished",
      denied: "status-chip denied"
    }

    content_tag(:span, t(status.to_s), class: status_classes[status.to_sym])
  end
end
