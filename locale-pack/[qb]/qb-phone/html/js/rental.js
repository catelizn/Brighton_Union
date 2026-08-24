var RentalApp = {};

function SetupRentalInfo(data) {
    var body = document.getElementById("rental-body");
    if (!body) return;
    body.innerHTML = "";

    if (!data) {
        body.innerHTML = '<div class="rental-empty"><i class="fas fa-car-side"></i><span>Активных аренд нет. Прокат — у Steve Carter в аэропорту.</span></div>';
        return;
    }

    var card = document.createElement("div");
    card.className = "rental-card";
    card.innerHTML =
        '<div class="rental-card-icon"><i class="fas fa-car-side"></i></div>' +
        '<div class="rental-card-info">' +
        '<div class="rental-card-label">' + data.label + '</div>' +
        '<div class="rental-card-plate">Госномер: ' + data.plate + '</div>' +
        '<div class="rental-card-time" id="rental-time">Осталось: —</div>' +
        '</div>';
    body.appendChild(card);

    var expiresAt = data.expiresAt;
    function tick() {
        var left = expiresAt - Math.floor(Date.now() / 1000);
        var el = document.getElementById("rental-time");
        if (!el) return;
        if (left <= 0) {
            el.textContent = "Аренда завершена";
            return;
        }
        var hours = Math.floor(left / 3600);
        var minutes = Math.floor((left % 3600) / 60);
        var seconds = left % 60;
        el.textContent = "Осталось: " + (hours > 0 ? hours + " ч " : "") + minutes + " мин " + seconds + " с";
    }
    tick();
    RentalApp.timer = setInterval(tick, 1000);
}
