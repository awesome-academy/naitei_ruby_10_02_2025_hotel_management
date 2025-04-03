document.addEventListener('turbo:load', function() {
  const urlPattern = /^\/(en|vi)\/admin\/room_types\/(\d+\/edit|new)$/;
  if (urlPattern.test(window.location.pathname)) {
    const addDeviceButton = document.getElementById('add-device');
    const deviceFields = document.getElementById('device-fields');

    if (!addDeviceButton || !deviceFields) return;

    let index = deviceFields.children.length;
    if (!addDeviceButton.dataset.listenerAdded) {
      addDeviceButton.dataset.listenerAdded = "true";

      addDeviceButton.addEventListener('click', function(e) {
        e.preventDefault();

        var newFields = `
          <div class='device-entry'>
            <input type='text' name='room_type[devices_attributes][${index}][name]' placeholder='Device Name' class='form-control'>
            <input type='number' name='room_type[devices_attributes][${index}][quantity]' placeholder='Quantity' class='form-control'>
            <input type='hidden' name='room_type[devices_attributes][${index}][_destroy]' value='false' class='device-destroy'>
            <a href='#' class='remove-device btn btn-danger text-white'>Remove</a>
          </div>`;

        deviceFields.insertAdjacentHTML('beforeend', newFields);
        index++; 
      });
    }

    document.addEventListener('click', function(e) {
      if (e.target && e.target.classList.contains('remove-device')) {
        e.preventDefault();
        let deviceEntry = e.target.closest('.device-entry');
        let destroyInput = deviceEntry.querySelector('.device-destroy');
        if (destroyInput) {
          destroyInput.value = 'true'; 
          deviceEntry.style.display = 'none'; 
        } else {
          deviceEntry.remove(); 
        }
      }
    });
  }
});
