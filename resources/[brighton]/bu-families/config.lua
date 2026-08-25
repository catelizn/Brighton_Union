Config = Config or {}

-- Семья: создание и управление — из планшета
Config.Family = {
    creationPrice = 25000,
    maxRank = 10,
    leaderRank = 10,
    maxMembers = 20
}

-- Фракция: задел на будущее (создание игроками не используется —
-- фракции на сервере пресетные: банды в bu-gangs, гос. структуры в qb-core)
Config.Faction = {
    creationPrice = 150000,
    maxRank = 12,
    leaderRank = 12,
    maxMembers = 30
}

Config.MaxNameLength = 24

-- Логи: сколько последних записей хранить и показывать
Config.LogKeep = 50

-- Контракты семей: доставка из точки А в точку Б, награда в казну
Config.Contracts = {
    { label = 'Доставка стройматериалов', reward = 15000, pickup = vector3(510.0, -2600.0, 6.0), drop = vector3(1700.0, 3300.0, 41.0) },
    { label = 'Перегон автомобиля',       reward = 12000, pickup = vector3(-40.0, -1080.0, 26.0), drop = vector3(900.0, -3000.0, 5.9) },
    { label = 'Доставка документов',      reward = 9000,  pickup = vector3(-550.0, -190.0, 38.0), drop = vector3(-1600.0, 5200.0, 3.0) },
    { label = 'Груз для порта',           reward = 18000, pickup = vector3(2900.0, 4300.0, 50.0), drop = vector3(450.0, -2800.0, 5.0) }
}
Config.ContractPickupRadius = 15.0
Config.ContractDropRadius = 25.0

-- Гараж семьи: глава покупает машины с казны, участники берут через телефон
Config.GarageVehicles = {
    { model = 'asea',      label = 'Asea',         price = 25000 },
    { model = 'sultan',    label = 'Sultan',       price = 45000 },
    { model = 'schafter2', label = 'Schafter V12', price = 90000 },
    { model = 'baller',    label = 'Baller',       price = 120000 }
}

-- Точки вызова машин в городе (телефон → приложение «Парковка»)
Config.ParkingPoints = {
    { name = 'Площадь Легион', coords = vector4(180.0, -910.0, 29.5, 90.0) },
    { name = 'Мэрия',          coords = vector4(-270.0, -950.0, 31.0, 90.0) },
    { name = 'Больница',       coords = vector4(320.0, -560.0, 43.0, 90.0) },
    { name = 'Банк',           coords = vector4(140.0, -1035.0, 29.4, 90.0) },
    { name = 'Аэропорт ЛС',    coords = vector4(-1010.0, -2720.0, 13.8, 90.0) },
    { name = 'Пляж Веспуччи',  coords = vector4(-1180.0, -1510.0, 4.0, 180.0) },
    { name = 'Магазин 24/7',   coords = vector4(25.0, -1346.0, 29.5, 90.0) }
}
Config.ParkingDistance = 35.0
