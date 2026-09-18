Config = Config or {}

-- Автошкола: здание DMV в центре города, у мэрии.
-- Наземная школа: высоты зафиксированы в конфиге (улица у DMV).
Config.Schools = {
    ground = {
        model = 'a_m_y_business_02',
        coords = vector4(240.4, -1379.8, 0.0, 140.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = { sprite = 225, color = 2, scale = 0.7, name = 'Автошкола' },
        spawn = vector4(247.0, -1372.0, 33.74, 140.0),
        returnPos = vector4(240.4, -1379.8, 33.74, 140.0),
        label = 'Автошкола'
    },
    air = {
        model = 's_m_m_pilot_01',
        coords = vector4(-1145.6, -2860.6, 13.94, 40.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = { sprite = 307, color = 2, scale = 0.7, name = 'Лётная школа' },
        spawn = vector4(-1158.0, -2870.0, 13.94, 40.0),
        returnPos = vector4(-1145.6, -2860.6, 13.94, 40.0),
        label = 'Лётная школа'
    }
}

-- Белые учебные машины на парковке автошколы
Config.SchoolCars = {
    models = { 'sultan', 'asea', 'washington', 'blista' },
    offsets = {
        vector3(-6.0, 3.0, 0.0),
        vector3(-3.0, 3.0, 0.0),
        vector3(0.0, 3.0, 0.0),
        vector3(3.0, 3.0, 0.0)
    }
}

Config.Categories = {
    ['A']  = { label = 'Категория A — мотоциклы',         price = 500,   vehicle = 'bati',     school = 'ground', theory = true },
    ['B']  = { label = 'Категория B — автомобили',        price = 1500,  vehicle = 'sultan',   school = 'ground', theory = true },
    ['C']  = { label = 'Категория C — грузовой транспорт', price = 3000, vehicle = 'boxville', school = 'ground', theory = true },
    ['LV'] = { label = 'Категория LV — вертолёты',         price = 20000, vehicle = 'maverick', school = 'air',    theory = false },
    ['LS'] = { label = 'Категория LS — самолёты',          price = 20000, vehicle = 'dodo',     school = 'air',    theory = false }
}

Config.ExamTimeLimit = 600
Config.ExamBucketBase = 100000 -- личный мир экзамена: bucket = base + playerId

-- Теория: 5 вопросов, для зачёта нужно 4 правильных
Config.TheoryPassCount = 4
Config.Theory = {
    {
        question = 'С какой стороны разрешён обгон на трассе?',
        options = { 'Справа', 'Слева', 'С любой стороны' },
        answer = 2
    },
    {
        question = 'Что означает красный сигнал светофора?',
        options = { 'Проезд разрешён', 'Остановка', 'Движение задним ходом' },
        answer = 2
    },
    {
        question = 'Можно ли управлять автомобилем без водительского удостоверения?',
        options = { 'Можно', 'Нельзя', 'Только ночью' },
        answer = 2
    },
    {
        question = 'Перед знаком STOP нужно...',
        options = { 'Полностью остановиться', 'Только притормозить', 'Проехать быстрее' },
        answer = 1
    },
    {
        question = 'Ремень безопасности нужно пристёгивать?',
        options = { 'Только на трассе', 'Всегда', 'Никогда' },
        answer = 2
    }
}

-- z = 0 для наземного маршрута: клиент сам найдёт высоту дороги
Config.Routes = {
    ground = {
        vector3(240.0, -1375.0, 0.0),
        vector3(220.0, -1310.0, 0.0),
        vector3(150.0, -1260.0, 0.0),
        vector3(80.0, -1150.0, 0.0),
        vector3(50.0, -1000.0, 0.0),
        vector3(120.0, -850.0, 0.0),
        vector3(230.0, -780.0, 0.0),
        vector3(320.0, -830.0, 0.0),
        vector3(380.0, -950.0, 0.0),
        vector3(330.0, -1100.0, 0.0),
        vector3(240.0, -1260.0, 0.0),
        vector3(240.0, -1375.0, 0.0)
    },
    air = {
        vector3(-1145.0, -2860.0, 45.0),
        vector3(-1300.0, -2600.0, 60.0),
        vector3(-1550.0, -2300.0, 80.0),
        vector3(-1800.0, -1900.0, 100.0),
        vector3(-1950.0, -1500.0, 100.0),
        vector3(-1700.0, -1200.0, 80.0),
        vector3(-1400.0, -900.0, 60.0),
        vector3(-1150.0, -700.0, 50.0),
        vector3(-1000.0, -1100.0, 40.0),
        vector3(-1145.0, -2860.0, 45.0)
    }
}

Config.CheckpointRadius = {
    ground = 15.0,
    air = 45.0
}

