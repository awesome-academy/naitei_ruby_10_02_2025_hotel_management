document.addEventListener("DOMContentLoaded", function() {
  document.getElementById("add-device").addEventListener("click", function(e) {
    e.preventDefault();
    
    var deviceFields = document.getElementById("device-fields");
    var index = deviceFields.children.length;
    
    var newFields = `
      <div class="device-entry">
        <input type="text" name="room_type[devices_attributes][${index}][name]" placeholder="Device Name" class="form-control">
        <input type="number" name="room_type[devices_attributes][${index}][quantity]" placeholder="Quantity" class="form-control">
        <a href="#" class="remove-device btn btn-danger"><i class="bi bi-trash-fill"></i></a>
      </div>`;
    
    deviceFields.insertAdjacentHTML("beforeend", newFields);
  });

  document.addEventListener("click", function(e) {
    if (e.target && e.target.classList.contains("remove-device")) {
      e.preventDefault();
      e.target.parentElement.remove();
    }
  });
});
