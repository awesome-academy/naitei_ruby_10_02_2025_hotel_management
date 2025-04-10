document.addEventListener('DOMContentLoaded', function () {
    const flashBox = document.getElementById('flash-message');

    const flashTypes = ['danger', 'success', 'info', 'notice'];
    flashTypes.forEach(function (type) {
        const message = sessionStorage.getItem('flash_' + type);
        if (message && flashBox) {
            flashBox.innerHTML += `<div class='alert alert-${type}'>${message}</div>`;
            sessionStorage.removeItem('flash_' + type);
        }
    });
});
