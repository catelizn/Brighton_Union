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
