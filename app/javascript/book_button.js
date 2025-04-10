document.addEventListener('turbo:load', () => {
    document.querySelectorAll('.book-button').forEach((btn) => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            const id = btn.dataset.roomTypeId;
            const q = document.getElementById(`quantity_${id}`).value;
            const checkin = btn.dataset.checkin;
            const checkout = btn.dataset.checkout;
            const url = `/user/requests/new?room_type_id=${id}&checkin_date=${checkin}&checkout_date=${checkout}&quantity=${q}`;
            window.location.href = url;
        });
    });
});
