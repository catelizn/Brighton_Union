Config = Config or {}

-- Жилые дома: покупка квартир через маркер у двери
Config.Buildings = {
    {
        key = 'rockford',
        label = 'Южный Рокфорд-Драйв',
        door = vector4(-667.02, -1105.24, 14.63, 242.0),
        apartments = 24,
        price = 150000
    },
    {
        key = 'morningwood',
        label = 'Морнингвуд-Бульвар',
        door = vector4(-1288.52, -430.51, 35.15, 124.0),
        apartments = 24,
        price = 180000
    },
    {
        key = 'integrity',
        label = 'Интегрити-Уэй',
        door = vector4(269.73, -640.75, 42.02, 249.0),
        apartments = 24,
        price = 160000
    }
}

-- Смещение интерьера вниз от двери, чтобы квартиры не пересекались
Config.InteriorOffsetBase = 300
Config.InteriorOffsetStep = 3

Config.TargetLabel = 'Жилой дом'
Config.MaxApartmentsPerBuilding = 1
