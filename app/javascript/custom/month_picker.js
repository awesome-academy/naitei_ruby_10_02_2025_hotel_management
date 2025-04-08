document.addEventListener('turbo:load', function () {
  const picker = document.getElementById('month-picker');
  if (!picker) return;
  picker.addEventListener('change', function () {
    const [year, month] = this.value.split('-');
    const url = new URL(window.location.href);
    url.searchParams.set('year', year);
    url.searchParams.set('month', parseInt(month));
    window.location.href = url.toString();
  });
});
