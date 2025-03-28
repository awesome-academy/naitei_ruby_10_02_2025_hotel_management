document.addEventListener('turbo:load', function () {
  const urlPattern = /^\/(en|vi)\/admin\/room_types\/(new|\d+\/edit)$/;
  if (urlPattern.test(window.location.pathname)) {
    const imageInput = document.getElementById('room_type_images');
    if (imageInput.dataset.listener === 'true') return;
    imageInput.dataset.listener = 'true';
    const previewContainer = document.createElement('div');
    previewContainer.classList.add('image-preview-container');
    imageInput.parentNode.insertBefore(previewContainer, imageInput.nextSibling);
    imageInput.addEventListener('change', function (event) {
      previewContainer.innerHTML = '';
      const files = event.target.files;

      Array.from(files).forEach((file) => {
        if (file.type.startsWith('image/')) {
          const reader = new FileReader();
          reader.onload = function (e) {
            const img = document.createElement('img');
            img.style.width = 'auto';
            img.style.height = '80px';
            img.src = e.target.result;
            img.classList.add('image-preview');
            previewContainer.appendChild(img);
          };
          reader.readAsDataURL(file);
        }
      });
    });
  }
});
