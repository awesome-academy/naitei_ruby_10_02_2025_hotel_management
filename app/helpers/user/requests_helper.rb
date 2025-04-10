module User::RequestsHelper
  def deposit_amount_display request
    amount = request.room_type.price * request.quantity * 0.5

    content_tag(:p) do
      content_tag(:strong, t("payment.deposit_amount")) + tag.br +
        number_to_currency(amount, unit: "", format: "%n đ")
    end
  end
end
