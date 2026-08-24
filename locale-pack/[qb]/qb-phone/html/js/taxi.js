function SetupTaxiInfo(data) {
    var body = document.getElementById("taxi-body");
    if (!body) return;
    body.innerHTML = "";

    if (!data) return;

    if (data.myOrder) {
        var statusText = data.myOrder.status === "open" ? "Ищем такси…" : "Такси едет!";
        var card = document.createElement("div");
        card.className = "rental-card";
        card.innerHTML =
            '<div class="rental-card-info" style="flex:1;">' +
            '<div class="rental-card-label">' + statusText + '</div>' +
            '<div class="rental-card-plate">Куда: ' + data.myOrder.destination + '</div>' +
            '<div class="rental-card-time">Цена: $' + Number(data.myOrder.price).toLocaleString("ru-RU") + '</div>' +
            '</div>';
        body.appendChild(card);
        return;
    }

    var title = document.createElement("div");
    title.className = "rental-card";
    title.innerHTML =
        '<div class="rental-card-info" style="flex:1;">' +
        '<div class="rental-card-label">Заказать такси</div>' +
        '<div class="rental-card-plate">Выбери, куда ехать. Цена — по расстоянию.</div>' +
        '</div>';
    body.appendChild(title);

    (data.destinations || []).forEach(function (destination) {
        var row = document.createElement("div");
        row.className = "rental-card";
        row.innerHTML =
            '<div class="rental-card-info" style="flex:1;">' +
            '<div class="rental-card-label">' + destination.label + '</div>' +
            '</div>' +
            '<button class="parking-button" data-dest="' + destination.index + '">Заказать</button>';
        body.appendChild(row);
    });

    body.querySelectorAll("[data-dest]").forEach(function (button) {
        button.addEventListener("click", function () {
            $.post('https://qb-phone/CreateTaxiOrder', JSON.stringify({ index: Number(button.dataset.dest) }));
            setTimeout(function () {
                $.post('https://qb-phone/GetTaxiData', JSON.stringify({}), function (fresh) {
                    SetupTaxiInfo(fresh);
                });
            }, 900);
        });
    });
}
