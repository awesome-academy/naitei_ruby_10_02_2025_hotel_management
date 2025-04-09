import '@hotwired/turbo-rails'
import 'controllers'
import 'custom/room_type_form'
import 'custom/upload_images'
import 'custom/month_picker'
import './book_button'
document.addEventListener('turbo:load', function () {
    document.getElementById('apply-dates').addEventListener('click', function (event) {
        event.preventDefault();
        var checkinDate = document.getElementById('check-in-date').value;
        var checkoutDate = document.getElementById('check-out-date').value;
        var url = '/user/room_types?checkin_date=' + checkinDate + '&checkout_date=' + checkoutDate;
        Turbo.visit(url);
    });
});
