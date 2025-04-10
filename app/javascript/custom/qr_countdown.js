document.addEventListener('turbo:load', function () {
    const timerElement = document.getElementById('countdown-timer');
    if (!timerElement) return;

    const requestId = timerElement.dataset.requestId;
    if (!requestId) return;

    const countdownKey = `countdown_start_${requestId}`;
    const duration = 1 * 60 * 1000;

    if (!localStorage.getItem(countdownKey)) {
        localStorage.setItem(countdownKey, Date.now().toString());
    }

    const startTime = parseInt(localStorage.getItem(countdownKey), 10);

    const updateCountdown = () => {
        const now = Date.now();
        const elapsed = now - startTime;
        const remaining = duration - elapsed;

        if (remaining <= 0) {
            clearInterval(countdownInterval);
            clearInterval(pollingInterval);
            timerElement.textContent = '00:00';
            localStorage.removeItem(countdownKey);

            const url = `/user/requests/${requestId}/expire`;
            const csrfToken = document.querySelector(`[name='csrf-token']`)?.content;

            fetch(url, {
                method: 'POST',
                headers: {
                    'X-CSRF-Token': csrfToken,
                    'Accept': 'application/json'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    if (data.flash?.danger) {
                        sessionStorage.setItem('flash_danger', data.flash.danger);
                    }
                    if (data.flash?.success) {
                        sessionStorage.setItem('flash_success', data.flash.success);
                    }
                    if (data.redirect) {
                        window.location.href = data.redirect;
                    }
                })
                .catch(() => window.location.href = '/');

            return;
        }

        const totalSeconds = Math.floor(remaining / 1000);
        const minutes = String(Math.floor(totalSeconds / 60)).padStart(2, '0');
        const seconds = String(totalSeconds % 60).padStart(2, '0');
        timerElement.textContent = `${minutes}:${seconds}`;
    };


    const countdownInterval = setInterval(updateCountdown, 1000);
    updateCountdown();

    const pollingInterval = setInterval(() => {
        fetch(`/user/requests/${requestId}/status_check`, {
            method: 'GET',
            headers: { 'Accept': 'application/json' },
            credentials: 'same-origin'
        })
            .then(response => response.json())
            .then(data => {
                if (data.deposited) {
                    clearInterval(countdownInterval);
                    clearInterval(pollingInterval);
                    if (data.flash?.success) {
                        sessionStorage.setItem('flash_success', data.flash.success);
                    }
                    window.location.href = data.redirect || '/';
                }
            })
            .catch(error => {
                console.error('Polling error:', error);
            });
    }, 7000);
});
