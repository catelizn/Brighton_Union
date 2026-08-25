Config = Config or {}

Config.OpenKey = 'DOWN'

Config.Documents = {
    { item = 'id_card', label = 'Удостоверение личности', icon = 'fa-id-card' },
    { item = 'driver_license', label = 'Водительское удостоверение', icon = 'fa-car' },
    { item = 'weaponlicense', label = 'Лицензия на оружие', icon = 'fa-gun' },
    { item = 'lawyerpass', label = 'Удостоверение адвоката', icon = 'fa-gavel' }
}

Config.DriverCategories = {
    ['Class A Driver License'] = 'Категория A',
    ['Class B Driver License'] = 'Категория B',
    ['Class C Driver License'] = 'Категория C',
    ['driver'] = 'Категория B',
    ['bike'] = 'Категория A',
    ['truck'] = 'Категория C'
}

Config.CategoryNames = {
    ['A'] = 'A (мото)',
    ['B'] = 'B (авто)',
    ['C'] = 'C (грузовики)',
    ['LV'] = 'Вертолёты',
    ['LS'] = 'Самолёты'
}

-- Даркнет: теневой маркет в планшете, заказ забирается в точке выдачи
Config.Darknet = {
    pickup = vector3(-1450.0, -520.0, 40.0),
    cooldownMinutes = 10,
    items = {
        { id = 'weapon_pistol',   label = 'Пистолет Walther P99', price = 25000 },
        { id = 'weapon_smg',      label = 'ПП SMG',               price = 60000 },
        { id = 'weapon_knife',    label = 'Нож',                  price = 3000 },
        { id = 'armor',           label = 'Бронежилет',           price = 5000 },
        { id = 'weapon_pumpshotgun', label = 'Помповый дробовик', price = 45000 }
    }
}
