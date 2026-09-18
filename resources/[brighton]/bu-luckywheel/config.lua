Config = Config or {}

-- Стоимость одного вращения и кулдаун (сек)
Config.Cost = 1000
Config.Cooldown = 60

-- Сектора колеса (порядок важен: индекс = сектор, на который указывает стрелка)
Config.Rewards = {
    { label = '$500',    type = 'cash', kind = 'cash', amount = 500 },
    { label = 'Мимо',     type = 'none' },
    { label = '$2500',   type = 'cash', kind = 'cash', amount = 2500 },
    { label = '$1000',   type = 'cash', kind = 'cash', amount = 1000 },
    { label = 'Джекпот', type = 'cash', kind = 'cash', amount = 10000 },
    { label = '$1500',   type = 'cash', kind = 'cash', amount = 1500 },
    { label = 'Мимо',     type = 'none' },
    { label = '$5000',   type = 'cash', kind = 'cash', amount = 5000 },
    { label = 'Мимо',     type = 'none' },
    { label = '$750',    type = 'cash', kind = 'cash', amount = 750 },
    { label = 'Мимо',     type = 'none' },
    { label = '$3000',   type = 'cash', kind = 'cash', amount = 3000 }
}

-- Точка в казино, где стоит колесо
Config.Spot = {
    coords = vector3(928.0, 47.0, 81.0),
    label = 'Колесо удачи'
}
