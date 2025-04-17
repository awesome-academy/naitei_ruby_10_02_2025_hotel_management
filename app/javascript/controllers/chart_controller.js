// app/javascript/controllers/checkout_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["roomTypeSelect"];

  update() {
    const selectedOption = this.roomTypeSelectTarget.selectedOptions[0].value
    const url = new URL(window.location.href);
    url.searchParams.set('room_type', selectedOption);
    window.location.href = url.toString();
  }
}
