Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.AvailableJobs = {                                     -- Only used when not using qb-jobs.
    ['tow'] = { ['label'] = 'Эвакуатор', ['isManaged'] = false },
    ['reporter'] = { ['label'] = 'Журналист', ['isManaged'] = false },
    ['garbage'] = { ['label'] = 'Мусорщик', ['isManaged'] = false },
    ['bus'] = { ['label'] = 'Водитель автобуса', ['isManaged'] = false },
    ['hotdog'] = { ['label'] = 'Продавец хот-догов', ['isManaged'] = false }
}

Config.Cityhalls = {
    { -- Cityhall 1
        coords = vec3(-265.0, -963.6, 31.2),
        showBlip = true,
        blipData = {
            sprite = 487,
            display = 4,
            scale = 0.65,
            colour = 0,
            title = 'Городские службы'
        },
        licenses = {
            ['id_card'] = {
                label = 'Удостоверение личности',
                cost = 50,
            },
            ['weaponlicense'] = {
                label = 'Лицензия на оружие',
                cost = 50,
                metadata = 'weapon'
            },
            ['hunting_license'] = {
                label = 'Лицензия на охоту',
                cost = 5000,
            },
            ['fishing_license'] = {
                label = 'Лицензия на рыбалку',
                cost = 2500,
            },
        }
    },
}

Config.DrivingSchools = {} -- Отключено: права выдаются через экзамены в bu-drivingschool

Config.Peds = {
    -- Cityhall Ped
    {
        model = 'a_m_m_hasjew_01',
        coords = vec4(-262.79, -964.18, 30.22, 181.71),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        cityhall = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0,
            debugPoly = false
        }
    },
}
