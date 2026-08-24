function SetupParkingInfo(data) {
    var body = document.getElementById("parking-body");
    if (!body) return;
    body.innerHTML = "";

    if (!data) return;

    var points = "";
    (data.points || []).forEach(function (point) {
        points += '<div class="rental-card-plate">• ' + point.name + '</div>';
    });

    var section = document.createElement("div");
    section.className = "rental-card";
    section.innerHTML =
        '<div class="rental-card-info" style="flex:1;">' +
        '<div class="rental-card-label">Точки вызова машин</div>' +
        '<div class="rental-card-time">Подойди к любой из точек и вызови машину из списка ниже.</div>' +
        points +
        '</div>';
    body.appendChild(section);

    (data.own || []).forEach(function (vehicle) {
        var card = document.createElement("div");
        card.className = "rental-card";
        card.innerHTML =
            '<div class="rental-card-info" style="flex:1;">' +
            '<div class="rental-card-label">' + vehicle.label + '</div>' +
            '<div class="rental-card-plate">' + vehicle.plate + '</div>' +
            '</div>' +
            '<button class="parking-button" data-act="call" data-plate="' + vehicle.plate + '">Вызвать</button>' +
            '<button class="parking-button" data-act="park" data-plate="' + vehicle.plate + '">Припарковать</button>';
        body.appendChild(card);
    });

    if (!data.family || data.family.length === 0) {
        var empty = document.createElement("div");
        empty.className = "rental-empty";
        empty.innerHTML = '<span>У организации машин нет. Глава может купить их в планшете.</span>';
        body.appendChild(empty);
    }

    (data.family || []).forEach(function (vehicle) {
        var card = document.createElement("div");
        card.className = "rental-card";
        card.innerHTML =
            '<div class="rental-card-info" style="flex:1;">' +
            '<div class="rental-card-label">' + vehicle.label + '</div>' +
            '<div class="rental-card-plate">' + vehicle.plate + ' • ' + (vehicle.inUse ? 'у участника' : 'в гараже') + '</div>' +
            '</div>' +
            (vehicle.inUse
                ? '<button class="parking-button" data-act="return" data-id="' + vehicle.id + '">Вернуть</button>'
                : '<button class="parking-button" data-act="take" data-id="' + vehicle.id + '">Взять</button>');
        body.appendChild(card);
    });

    body.querySelectorAll(".parking-button").forEach(function (button) {
        button.addEventListener("click", function () {
            var act = button.dataset.act;
            if (act === "call") {
                $.post('https://qb-phone/CallOwnVehicle', JSON.stringify({ plate: button.dataset.plate }));
            } else if (act === "park") {
                $.post('https://qb-phone/ParkOwnVehicle', JSON.stringify({ plate: button.dataset.plate }));
            } else if (act === "take") {
                $.post('https://qb-phone/TakeFamilyVehicle', JSON.stringify({ id: Number(button.dataset.id) }));
            } else if (act === "return") {
                $.post('https://qb-phone/ReturnFamilyVehicle', JSON.stringify({ id: Number(button.dataset.id) }));
            }
            setTimeout(function () {
                $.post('https://qb-phone/GetParkingData', JSON.stringify({}), function (fresh) {
                    SetupParkingInfo(fresh);
                });
            }, 900);
        });
    });
}
