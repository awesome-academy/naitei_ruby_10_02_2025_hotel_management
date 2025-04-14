// app/javascript/controllers/checkout_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['row', 'addButton', 'totalPrice', 'roomTotalPrice', 'totalServicePrice'];

  connect() {
    this.count = this.rowTargets.length;
    this.element.addEventListener('service-field:changed', this.updateTotalPrice.bind(this))
  }

  addRow() {
    const newRow = this.rowTargets[0].cloneNode(true);
    const inputs = newRow.querySelectorAll('input, select');
    inputs.forEach(input => {
      const name = input.name.replace(/\[\d+\]/, `[${this.count}]`);
      input.name = name;
      input.value = "";
    });

    const priceDiv = newRow.querySelector('[data-service-field-target="price"]');
    const totalDiv = newRow.querySelector('[data-service-field-target="total"]');

    if (priceDiv) priceDiv.textContent = '';
    if (totalDiv) totalDiv.textContent = '';

    this.rowTargets[0].parentNode.insertBefore(newRow, this.addButtonTarget);
    this.count++;
  }

  updateTotalPrice() {
    let total = 0;
    this.rowTargets.forEach(row => {
      const select = row.querySelector("[data-service-field-target='select']");
      const quantity = parseInt(row.querySelector("[data-service-field-target='quantity']")?.value || 0);
      const price = parseFloat(select?.selectedOptions[0]?.dataset?.price || 0);
      total += price * quantity;
    });
    const roomPrice = parseFloat(this.roomTotalPriceTarget.textContent.replace(/[₫.]/g, '')) || 0;
    this.totalServicePriceTarget.textContent = total ? `${total.toLocaleString()}₫` : '0₫';
    this.totalPriceTarget.textContent = `${(total + roomPrice).toLocaleString()}₫`;
  }
}
