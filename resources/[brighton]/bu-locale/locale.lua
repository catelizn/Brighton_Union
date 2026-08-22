if GetConvar('qb_locale', 'en') ~= 'ru' then return end

local QBCore = exports['qb-core']:GetCoreObject()

local jobLabels = {
    unemployed = 'Гражданский',
    bus = 'Автобусный парк',
    judge = 'Судебная система',
    lawyer = 'Юридическая фирма',
    reporter = 'Журналист',
    trucker = 'Дальнобойщик',
    tow = 'Эвакуация',
    garbage = 'Вывоз мусора',
    vineyard = 'Виноградник',
    hotdog = 'Продавец хот-догов',
    police = 'Полиция',
    ambulance = 'Скорая помощь',
    realestate = 'Риэлтор',
    taxi = 'Такси',
    cardealer = 'Автодилер',
    mechanic = 'LS Customs',
    mechanic2 = 'LS Customs',
    mechanic3 = 'LS Customs',
    beeker = "Beeker's Garage",
    bennys = "Benny's Original Motor Works",
}

local gradeNames = {
    Freelancer = 'Фрилансер',
    Driver = 'Водитель',
    Judge = 'Судья',
    Associate = 'Помощник',
    Journalist = 'Журналист',
    Collector = 'Сборщик',
    Picker = 'Сборщик',
    Sales = 'Продавец',
    Recruit = 'Стажёр',
    Officer = 'Офицер',
    Sergeant = 'Сержант',
    Lieutenant = 'Лейтенант',
    Chief = 'Шеф',
    Paramedic = 'Парамедик',
    Doctor = 'Врач',
    Surgeon = 'Хирург',
    ['House Sales'] = 'Продажи домов',
    ['Business Sales'] = 'Продажи бизнеса',
    Broker = 'Брокер',
    Manager = 'Менеджер',
    ['Event Driver'] = 'Водитель мероприятий',
    ['Showroom Sales'] = 'Продажи в салоне',
    Finance = 'Финансы',
    Novice = 'Новичок',
    Experienced = 'Опытный',
    Advanced = 'Продвинутый',
}

for jobName, job in pairs(QBCore.Shared.Jobs) do
    if jobLabels[jobName] then
        job.label = jobLabels[jobName]
    end
    for _, grade in pairs(job.grades) do
        if gradeNames[grade.name] then
            grade.name = gradeNames[grade.name]
        end
    end
end
