// app/javascript/controllers/checkout_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['select', 'price', 'quantity', 'total']

  update() {
    const selectedOption = this.selectTarget.selectedOptions[0]
    const price = selectedOption?.dataset?.price
    this.quantityTarget.value = 1
    this.priceTarget.textContent = price ? `${price}₫` : ''
    this.calculateTotal()
  }

  calculateTotal() {
    const selectedOption = this.selectTarget.selectedOptions[0]
    const price = parseFloat(selectedOption?.dataset?.price || 0)
    const quantity = parseInt(this.quantityTarget.value || 0)
    const total = price * quantity
    this.totalTarget.textContent = total ? `${total}₫` : ''

    this.dispatch('changed', { detail: { total } })
  }
}
