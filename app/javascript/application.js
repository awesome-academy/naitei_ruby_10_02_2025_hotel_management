import '@hotwired/turbo-rails'
import 'controllers'
import 'custom/room_type_form'
import 'custom/upload_images'
import 'custom/month_picker'
import './book_button'
import 'custom/qr_countdown'
import './flash_session'
document.addEventListener('turbo:load', function () {
    const applyDate = document.getElementById('apply-dates');
    if (!applyDate) return;

    applyDate.addEventListener('click', function (event) {
        event.preventDefault();
        var checkinDate = document.getElementById('check-in-date').value;
        var checkoutDate = document.getElementById('check-out-date').value;
        var url = '/user/room_types?checkin_date=' + checkinDate + '&checkout_date=' + checkoutDate;
        Turbo.visit(url);
    });
});
