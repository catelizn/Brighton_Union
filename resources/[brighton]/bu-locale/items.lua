-- Russian labels and descriptions for QBCore items.
-- Applied only when qb_locale == 'ru'.

local QBCore = exports['qb-core']:GetCoreObject()

local itemOverrides = {
    -- Weapons / melee
    weapon_unarmed               = { label = 'Кулаки', description = 'Кулачный бой' },
    weapon_dagger                = { label = 'Кинжал', description = 'Короткий нож с заострённым лезвием, используется как оружие' },
    weapon_bat                   = { label = 'Бита', description = 'Для игры в бейсбол (или для других дел)' },
    weapon_bottle                = { label = 'Разбитая бутылка', description = 'Разбитая бутылка' },
    weapon_crowbar               = { label = 'Лом', description = 'Железный прут с расплющенным концом, используется как рычаг' },
    weapon_flashlight            = { label = 'Фонарик', description = 'Портативный фонарь на батарейках' },
    weapon_golfclub              = { label = 'Клюшка для гольфа', description = 'Клюшка, которой бьют мяч в гольфе' },
    weapon_hammer                = { label = 'Молоток', description = 'Пригодится, например, чтобы ломать вещи и забивать гвозди' },
    weapon_hatchet               = { label = 'Топорик', description = 'Небольшой топор с короткой рукоятью' },
    weapon_knuckle               = { label = 'Кастет', description = 'Металлическая пластина на костяшки для усиления ударов' },
    weapon_knife                 = { label = 'Нож', description = 'Лезвие, закреплённое в рукояти, для резки или как оружие' },
    weapon_machete               = { label = 'Мачете', description = 'Широкий тяжёлый нож, используется как оружие' },
    weapon_switchblade           = { label = 'Выкидной нож', description = 'Нож с лезвием, выскакивающим из рукояти при нажатии кнопки' },
    weapon_nightstick            = { label = 'Дубинка', description = 'Полицейская дубинка' },
    weapon_wrench                = { label = 'Гаечный ключ', description = 'Инструмент для затягивания гаек и болтов' },
    weapon_battleaxe             = { label = 'Боевой топор', description = 'Большой топор с широким лезвием' },
    weapon_poolcue               = { label = 'Кий', description = 'Палка для игры в бильярд (или для других дел)' },
    weapon_briefcase             = { label = 'Портфель', description = 'Портфель для важных документов' },
    weapon_briefcase_02          = { label = 'Чемодан', description = 'Отлично подойдёт для отпуска в Либерти-Сити' },
    weapon_garbagebag            = { label = 'Мусорный пакет', description = 'Мусорный пакет' },
    weapon_handcuffs             = { label = 'Наручники', description = 'Пара металлических колец для фиксации запястий' },
    weapon_bread                 = { label = 'Багет', description = 'Хлеб...?' },
    weapon_stone_hatchet         = { label = 'Каменный топор', description = 'Каменный топор' },
    weapon_candycane             = { label = 'Леденец-трость', description = 'Леденец-трость' },

    -- Handguns
    weapon_pistol                = { label = 'Walther P99', description = 'Небольшой пистолет для стрельбы одной рукой' },
    weapon_pistol_mk2            = { label = 'Пистолет Mk II', description = 'Улучшенный пистолет для стрельбы одной рукой' },
    weapon_combatpistol          = { label = 'Боевой пистолет', description = 'Боевая версия пистолета для стрельбы одной рукой' },
    weapon_appistol              = { label = 'AP Пистолет', description = 'Небольшой автоматический пистолет' },
    weapon_stungun               = { label = 'Тазер', description = 'Бьёт током по проводам — парализует на пару секунд' },
    weapon_pistol50              = { label = 'Пистолет .50', description = 'Пистолет калибра .50 для стрельбы двумя руками' },
    weapon_snspistol             = { label = 'SNS Пистолет', description = 'Очень маленький пистолет, который легко спрятать' },
    weapon_heavypistol           = { label = 'Тяжёлый пистолет', description = 'Массивный пистолет для стрельбы одной рукой' },
    weapon_vintagepistol         = { label = 'Винтажный пистолет', description = 'Антикварный пистолет для стрельбы одной рукой' },
    weapon_flaregun              = { label = 'Сигнальный пистолет', description = 'Пистолет для запуска сигнальных ракет' },
    weapon_marksmanpistol        = { label = 'Снайперский пистолет', description = 'Очень точный пистолет для стрельбы одной рукой' },
    weapon_revolver              = { label = 'Револьвер', description = 'Револьвер с барабаном: несколько выстрелов без перезарядки' },
    weapon_revolver_mk2          = { label = 'Револьвер Mk II', description = 'Мощный револьвер с барабаном на шесть патронов' },
    weapon_doubleaction          = { label = 'Револьвер двойного действия', description = 'Револьвер двойного действия' },
    weapon_snspistol_mk2         = { label = 'SNS Пистолет Mk II', description = 'SNS Пистолет Mk II' },
    weapon_raypistol             = { label = 'Up-n-Atomizer', description = 'Up-n-Atomizer' },
    weapon_ceramicpistol         = { label = 'Керамический пистолет', description = 'Керамический пистолет' },
    weapon_navyrevolver          = { label = 'Морской револьвер', description = 'Морской револьвер' },
    weapon_gadgetpistol          = { label = 'Perico Pistol', description = 'Perico Pistol' },
    weapon_pistolxm3             = { label = 'Пистолет XM3', description = 'Пистолет XM3' },

    -- Submachine guns
    weapon_microsmg              = { label = 'Микро ПП', description = 'Лёгкий ручной пулемёт' },
    weapon_smg                   = { label = 'ПП', description = 'Лёгкий ручной пулемёт' },
    weapon_smg_mk2               = { label = 'ПП Mk II', description = 'ПП Mk II' },
    weapon_assaultsmg            = { label = 'Штурмовой ПП', description = 'Штурмовая версия лёгкого ручного пулемёта' },
    weapon_combatpdw             = { label = 'Боевой PDW', description = 'Боевая версия лёгкого ручного пулемёта' },
    weapon_machinepistol         = { label = 'Tec-9', description = 'Пистолет, стреляющий очередями' },
    weapon_minismg               = { label = 'Мини ПП', description = 'Миниатюрный лёгкий ручной пулемёт' },
    weapon_raycarbine            = { label = 'Unholy Hellbringer', description = 'Unholy Hellbringer' },

    -- Shotguns
    weapon_pumpshotgun           = { label = 'Помповый дробовик', description = 'Помповое ружьё для стрельбы дробью на короткой дистанции' },
    weapon_sawnoffshotgun        = { label = 'Обрез', description = 'Укороченное ружьё для стрельбы дробью на короткой дистанции' },
    weapon_assaultshotgun        = { label = 'Штурмовой дробовик', description = 'Штурмовая версия ружья для стрельбы дробью' },
    weapon_bullpupshotgun        = { label = 'Буллпап-дробовик', description = 'Компактное ружьё для стрельбы дробью' },
    weapon_musket                = { label = 'Мушкет', description = 'Лёгкое ружьё с длинным стволом, заряжается с дула' },
    weapon_heavyshotgun          = { label = 'Тяжёлый дробовик', description = 'Большое ружьё для стрельбы дробью' },
    weapon_dbshotgun             = { label = 'Двустволка', description = 'Двуствольное ружьё — два выстрела подряд' },
    weapon_autoshotgun           = { label = 'Автоматический дробовик', description = 'Дробовик, способный вести непрерывный огонь' },
    weapon_pumpshotgun_mk2       = { label = 'Помповый дробовик Mk II', description = 'Помповый дробовик Mk II' },
    weapon_combatshotgun         = { label = 'Боевой дробовик', description = 'Боевой дробовик' },

    -- Assault rifles
    weapon_assaultrifle          = { label = 'Штурмовая винтовка', description = 'Скорострельная автоматическая винтовка с магазинным питанием' },
    weapon_assaultrifle_mk2      = { label = 'Штурмовая винтовка Mk II', description = 'Штурмовая винтовка Mk II' },
    weapon_carbinerifle          = { label = 'Карабин', description = 'Лёгкая автоматическая винтовка' },
    weapon_carbinerifle_mk2      = { label = 'Карабин Mk II', description = 'Карабин Mk II' },
    weapon_advancedrifle         = { label = 'Продвинутая винтовка', description = 'Улучшенная скорострельная автоматическая винтовка' },
    weapon_specialcarbine        = { label = 'Специальный карабин', description = 'Универсальная штурмовая винтовка для любых ситуаций' },
    weapon_bullpuprifle          = { label = 'Буллпап-винтовка', description = 'Компактная автоматическая винтовка' },
    weapon_compactrifle          = { label = 'Компактная винтовка', description = 'Компактная версия штурмовой винтовки' },
    weapon_specialcarbine_mk2    = { label = 'Специальный карабин Mk II', description = 'Специальный карабин Mk II' },
    weapon_bullpuprifle_mk2      = { label = 'Буллпап-винтовка Mk II', description = 'Буллпап-винтовка Mk II' },
    weapon_militaryrifle         = { label = 'Военная винтовка', description = 'Военная винтовка' },

    -- Machine guns
    weapon_mg                    = { label = 'Пулемёт', description = 'Автоматическое оружие, стреляющее очередями, пока нажат спуск' },
    weapon_combatmg              = { label = 'Боевой пулемёт', description = 'Боевая версия пулемёта' },
    weapon_gusenberg             = { label = 'Thompson SMG', description = 'Автомат, известный как «Томми-ган»' },
    weapon_combatmg_mk2          = { label = 'Боевой пулемёт Mk II', description = 'Боевой пулемёт Mk II' },

    -- Sniper rifles
    weapon_sniperrifle           = { label = 'Снайперская винтовка', description = 'Высокоточная дальнобойная винтовка' },
    weapon_heavysniper           = { label = 'Тяжёлая снайперская винтовка', description = 'Улучшенная высокоточная дальнобойная винтовка' },
    weapon_marksmanrifle         = { label = 'Марксманская винтовка', description = 'Очень точная винтовка с одиночной стрельбой' },
    weapon_remotesniper          = { label = 'Дистанционная винтовка', description = 'Портативная высокоточная дальнобойная винтовка' },
    weapon_heavysniper_mk2       = { label = 'Тяжёлая снайперская винтовка Mk II', description = 'Тяжёлая снайперская винтовка Mk II' },
    weapon_marksmanrifle_mk2     = { label = 'Марксманская винтовка Mk II', description = 'Марксманская винтовка Mk II' },

    -- Heavy weapons
    weapon_rpg                   = { label = 'RPG', description = 'Ручной противотанковый гранатомёт' },
    weapon_grenadelauncher       = { label = 'Гранатомёт', description = 'Оружие, стреляющее крупнокалиберными снарядами' },
    weapon_grenadelauncher_smoke = { label = 'Дымовой гранатомёт', description = 'Выпускает много дыма при взрыве' },
    weapon_minigun               = { label = 'Миниган', description = 'Портативный шестиствольный пулемёт со скорострельностью до 6000 выстрелов в минуту' },
    weapon_firework              = { label = 'Пусковая установка фейерверков', description = 'Палит фейерверком — зажигай фитиль' },
    weapon_railgun               = { label = 'Рельсотрон', description = 'Оружие, разгоняющее снаряды электромагнитным полем' },
    weapon_railgunxm3            = { label = 'Рельсотрон XM3', description = 'Оружие, разгоняющее снаряды электромагнитным полем' },
    weapon_hominglauncher        = { label = 'Самонаводящийся гранатомёт', description = 'Оружие с электронным наведением на цель' },
    weapon_compactlauncher       = { label = 'Компактный гранатомёт', description = 'Компактный гранатомёт' },
    weapon_rayminigun            = { label = 'Widowmaker', description = 'Widowmaker' },

    -- Throwables
    weapon_grenade               = { label = 'Граната', description = 'Ручная метательная бомба' },
    weapon_bzgas                 = { label = 'Газ BZ', description = 'Баллончик с газом, вызывающим сильную боль' },
    weapon_molotov               = { label = 'Коктейль Молотова', description = 'Самодельная бомба из бутылки с горючей жидкостью и фитилём' },
    weapon_stickybomb            = { label = 'C4', description = 'Взрывчатка с липким слоем, прилипающая к поверхности до взрыва' },
    weapon_proxmine              = { label = 'Мина', description = 'Бомба, срабатывающая при приближении' },
    weapon_snowball              = { label = 'Снежок', description = 'Шар из спрессованного снега, для весёлых перестрелок' },
    weapon_pipebomb              = { label = 'Самодельная бомба', description = 'Самодельная бомба из трубы' },
    weapon_ball                  = { label = 'Мяч', description = 'Предмет для спортивных игр' },
    weapon_smokegrenade          = { label = 'Дымовая граната', description = 'Заряд, создающий дымовую завесу' },
    weapon_flare                 = { label = 'Сигнальная ракета', description = 'Пиротехническое устройство для освещения и сигналов' },

    -- Miscellaneous weapons
    weapon_petrolcan             = { label = 'Канистра с бензином', description = 'Прочная металлическая ёмкость для жидкости' },
    weapon_fireextinguisher      = { label = 'Огнетушитель', description = 'Устройство для тушения пожаров' },
    weapon_hazardcan             = { label = 'Канистра с опасным веществом', description = 'Канистра с опасным веществом' },

    -- Attachments
    clip_attachment              = { label = 'Магазин', description = 'Магазин для оружия' },
    drum_attachment              = { label = 'Барабанный магазин', description = 'Барабанный магазин для оружия' },
    flashlight_attachment        = { label = 'Фонарик', description = 'Фонарик для оружия' },
    suppressor_attachment        = { label = 'Глушитель', description = 'Глушитель для оружия' },
    smallscope_attachment        = { label = 'Малый прицел', description = 'Малый прицел для оружия' },
    medscope_attachment          = { label = 'Средний прицел', description = 'Средний прицел для оружия' },
    largescope_attachment        = { label = 'Большой прицел', description = 'Большой прицел для оружия' },
    holoscope_attachment         = { label = 'Голографический прицел', description = 'Голографический прицел для оружия' },
    advscope_attachment          = { label = 'Продвинутый прицел', description = 'Продвинутый прицел для оружия' },
    nvscope_attachment           = { label = 'Прицел ночного видения', description = 'Прицел ночного видения для оружия' },
    thermalscope_attachment      = { label = 'Тепловой прицел', description = 'Тепловой прицел для оружия' },
    flat_muzzle_brake            = { label = 'Плоский дульный тормоз', description = 'Дульный тормоз для оружия' },
    tactical_muzzle_brake        = { label = 'Тактический дульный тормоз', description = 'Дульный тормоз для оружия' },
    fat_end_muzzle_brake         = { label = 'Утолщённый дульный тормоз', description = 'Дульный тормоз для оружия' },
    precision_muzzle_brake       = { label = 'Точный дульный тормоз', description = 'Дульный тормоз для оружия' },
    heavy_duty_muzzle_brake      = { label = 'Усиленный дульный тормоз', description = 'Дульный тормоз для оружия' },
    slanted_muzzle_brake         = { label = 'Скошенный дульный тормоз', description = 'Дульный тормоз для оружия' },
    split_end_muzzle_brake       = { label = 'Раздвоенный дульный тормоз', description = 'Дульный тормоз для оружия' },
    squared_muzzle_brake         = { label = 'Квадратный дульный тормоз', description = 'Дульный тормоз для оружия' },
    bellend_muzzle_brake         = { label = 'Раструбный дульный тормоз', description = 'Дульный тормоз для оружия' },
    barrel_attachment            = { label = 'Ствол', description = 'Ствол для оружия' },
    grip_attachment              = { label = 'Рукоять', description = 'Рукоять для оружия' },
    comp_attachment              = { label = 'Компенсатор', description = 'Компенсатор для оружия' },
    luxuryfinish_attachment      = { label = 'Люксовая отделка', description = 'Люксовая отделка для оружия' },
    digicamo_attachment          = { label = 'Цифровой камуфляж', description = 'Цифровой камуфляж для оружия' },
    brushcamo_attachment         = { label = 'Маскировочная окраска', description = 'Маскировочная окраска для оружия' },
    woodcamo_attachment          = { label = 'Лесной камуфляж', description = 'Лесной камуфляж для оружия' },
    skullcamo_attachment         = { label = 'Камуфляж «Череп»', description = 'Камуфляж с черепами для оружия' },
    sessantacamo_attachment      = { label = 'Камуфляж Sessanta Nove', description = 'Камуфляж Sessanta Nove для оружия' },
    perseuscamo_attachment       = { label = 'Камуфляж Perseus', description = 'Камуфляж Perseus для оружия' },
    leopardcamo_attachment       = { label = 'Леопардовый камуфляж', description = 'Леопардовый камуфляж для оружия' },
    zebracamo_attachment         = { label = 'Камуфляж «Зебра»', description = 'Камуфляж «Зебра» для оружия' },
    geocamo_attachment           = { label = 'Геометрический камуфляж', description = 'Геометрический камуфляж для оружия' },
    boomcamo_attachment          = { label = 'Камуфляж Boom', description = 'Камуфляж Boom для оружия' },
    patriotcamo_attachment       = { label = 'Патриотический камуфляж', description = 'Патриотический камуфляж для оружия' },

    -- Ammo
    pistol_ammo                  = { label = 'Патроны для пистолета', description = 'Патроны для пистолетов' },
    rifle_ammo                   = { label = 'Патроны для винтовки', description = 'Патроны для винтовок' },
    smg_ammo                     = { label = 'Патроны для ПП', description = 'Патроны для пистолетов-пулемётов' },
    shotgun_ammo                 = { label = 'Патроны для дробовика', description = 'Патроны для дробовиков' },
    mg_ammo                      = { label = 'Патроны для пулемёта', description = 'Патроны для пулемётов' },
    snp_ammo                     = { label = 'Снайперские патроны', description = 'Патроны для снайперских винтовок' },
    emp_ammo                     = { label = 'EMP-патроны', description = 'Патроны для EMP-оружия' },

    -- Cards
    id_card                      = { label = 'Удостоверение личности', description = 'Карта со всей вашей информацией для идентификации' },
    driver_license               = { label = 'Водительское удостоверение', description = 'Документ, подтверждающий право управлять транспортом' },
    lawyerpass                   = { label = 'Удостоверение адвоката', description = 'Документ, дающий адвокату право представлять подозреваемого' },
    weaponlicense                = { label = 'Лицензия на оружие', description = 'Лицензия на оружие' },
    bank_card                    = { label = 'Банковская карта', description = 'Для доступа к банкомату' },
    security_card_01             = { label = 'Карта доступа A', description = 'Карта доступа... Интересно, куда она подходит' },
    security_card_02             = { label = 'Карта доступа B', description = 'Карта доступа... Интересно, куда она подходит' },

    -- Food
    tosti                        = { label = 'Сэндвич с сыром', description = 'Вкусно' },
    twerks_candy                 = { label = 'Twerks', description = 'Вкусная конфета :O' },
    snikkel_candy                = { label = 'Snikkel', description = 'Вкусная конфета :O' },
    sandwich                     = { label = 'Сэндвич', description = 'Хороший хлеб для твоего желудка' },

    -- Drinks
    water_bottle                 = { label = 'Бутылка воды', description = 'Для всех, кто хочет пить' },
    coffee                       = { label = 'Кофе', description = 'Заряд кофеина' },
    kurkakola                    = { label = 'Кола', description = 'Для всех, кто хочет пить' },

    -- Alcohol
    beer                         = { label = 'Пиво', description = 'Нет ничего лучше холодного пива!' },
    whiskey                      = { label = 'Виски', description = 'Для тех, кто хочет согреться' },
    vodka                        = { label = 'Водка', description = 'Для тех, кто хочет согреться' },
    grape                        = { label = 'Виноград', description = 'Ммм, вкусный виноград' },
    wine                         = { label = 'Вино', description = 'Хорошее вино для приятного вечера' },
    grapejuice                   = { label = 'Виноградный сок', description = 'Говорят, виноградный сок полезен' },

    -- Drugs
    joint                        = { label = 'Косяк', description = 'Сидни бы вами гордился' },
    cokebaggy                    = { label = 'Пакетик кокаина', description = 'Чтобы быстро стать счастливым' },
    crack_baggy                  = { label = 'Пакетик крэка', description = 'Чтобы стать счастливым ещё быстрее' },
    xtcbaggy                     = { label = 'Пакетик экстази', description = 'Прими таблетку, детка' },
    coke_brick                   = { label = 'Кирпич кокаина', description = 'Крупная партия кокаина, обычно для сделок' },
    weed_brick                   = { label = 'Кирпич травы', description = '1 кг травы для продажи крупным покупателям.' },
    coke_small_brick             = { label = 'Пакет кокаина', description = 'Небольшая партия кокаина, обычно для сделок' },
    oxy                          = { label = 'Рецептурный окси', description = 'Этикетка оторвана' },
    meth                         = { label = 'Мет', description = 'Пакетик мета' },
    rolling_paper                = { label = 'Бумага для самокруток', description = 'Бумага для скручивания табака или травы' },

    -- Weed
    weed_whitewidow              = { label = 'White Widow 2г', description = 'Пакетик травы: 2г White Widow' },
    weed_skunk                   = { label = 'Skunk 2г', description = 'Пакетик травы: 2г Skunk' },
    weed_purplehaze              = { label = 'Purple Haze 2г', description = 'Пакетик травы: 2г Purple Haze' },
    weed_ogkush                  = { label = 'OG Kush 2г', description = 'Пакетик травы: 2г OG Kush' },
    weed_amnesia                 = { label = 'Amnesia 2г', description = 'Пакетик травы: 2г Amnesia' },
    weed_ak47                    = { label = 'AK-47 2г', description = 'Пакетик травы: 2г AK-47' },
    weed_whitewidow_seed         = { label = 'Семена White Widow', description = 'Семя травы White Widow' },
    weed_skunk_seed              = { label = 'Семена Skunk', description = 'Семя травы Skunk' },
    weed_purplehaze_seed         = { label = 'Семена Purple Haze', description = 'Семя травы Purple Haze' },
    weed_ogkush_seed             = { label = 'Семена OG Kush', description = 'Семя травы OG Kush' },
    weed_amnesia_seed            = { label = 'Семена Amnesia', description = 'Семя травы Amnesia' },
    weed_ak47_seed               = { label = 'Семена AK-47', description = 'Семя травы AK-47' },
    empty_weed_bag               = { label = 'Пустой пакет', description = 'Небольшой пустой пакет' },
    weed_nutrition               = { label = 'Удобрение для растений', description = 'Подкормка для растений' },

    -- Materials
    plastic                      = { label = 'Пластик', description = 'Сдавайте на переработку!' },
    metalscrap                   = { label = 'Металлолом', description = 'Из этого наверняка можно сделать что-то полезное' },
    copper                       = { label = 'Медь', description = 'Скупщики платят за медь неплохо' },
    aluminum                     = { label = 'Алюминий', description = 'Лёгкий и ходовой металл' },
    aluminumoxide                = { label = 'Алюминиевый порошок', description = 'Порошок для смешивания' },
    iron                         = { label = 'Железо', description = 'Пригодится в кузне' },
    ironoxide                    = { label = 'Железный порошок', description = 'Порошок для смешивания.' },
    steel                        = { label = 'Сталь', description = 'Крепче железа — и в скупке дороже' },
    rubber                       = { label = 'Резина', description = 'Из резины можно сделать даже резиновую уточку :D' },
    glass                        = { label = 'Стекло', description = 'Очень хрупкое, осторожнее' },

    -- Tools
    lockpick                     = { label = 'Отмычка', description = 'Пригодится, если часто теряешь ключи... или для других целей...' },
    advancedlockpick             = { label = 'Улучшенная отмычка', description = 'Если часто теряешь ключи — это очень полезно... Ещё ей можно открывать пиво' },
    electronickit                = { label = 'Набор электроники', description = 'Если всегда мечтал собрать робота — начни отсюда. Может, станешь новым Илоном Маском?' },
    gatecrack                    = { label = 'Gatecrack', description = 'Удобная программа для взлома ограждений' },
    thermite                     = { label = 'Термит', description = 'Иногда хочется, чтобы всё сгорело' },
    trojan_usb                   = { label = 'Троянский USB', description = 'Удобная программа для отключения систем' },
    screwdriverset               = { label = 'Набор инструментов', description = 'Очень удобно для закручивания... винтов...' },
    drill                        = { label = 'Дрель', description = 'Серьёзная штука...' },

    -- Vehicle tools
    nitrous                      = { label = 'Нитро', description = 'Жми на газ! :D' },
    repairkit                    = { label = 'Ремкомплект', description = 'Набор инструментов для ремонта машины' },
    advancedrepairkit            = { label = 'Продвинутый ремкомплект', description = 'Набор инструментов для ремонта машины' },
    cleaningkit                  = { label = 'Набор для мойки', description = 'Тряпка и мыло — и машина снова сверкает!' },
    tunerlaptop                  = { label = 'Чип-тюнер', description = 'С этим чипом машина станет зверем... Если знаешь, что делаешь' },
    harness                      = { label = 'Гоночный ремень', description = 'Гоночный ремень, чтобы оставаться в машине в любой ситуации' },
    jerry_can                    = { label = 'Канистра 20л', description = 'Канистра, полная топлива' },
    tirerepairkit                = { label = 'Набор для ремонта шин', description = 'Набор для ремонта шин' },

    -- Mechanic parts
    veh_toolbox                  = { label = 'Набор инструментов', description = 'Проверить состояние машины' },
    veh_armor                    = { label = 'Броня', description = 'Улучшить броню машины' },
    veh_brakes                   = { label = 'Тормоза', description = 'Улучшить тормоза машины' },
    veh_engine                   = { label = 'Двигатель', description = 'Улучшить двигатель машины' },
    veh_suspension               = { label = 'Подвеска', description = 'Улучшить подвеску машины' },
    veh_transmission             = { label = 'Трансмиссия', description = 'Улучшить трансмиссию машины' },
    veh_turbo                    = { label = 'Турбо', description = 'Установить турбо на машину' },
    veh_interior                 = { label = 'Интерьер', description = 'Улучшить интерьер машины' },
    veh_exterior                 = { label = 'Экстерьер', description = 'Улучшить экстерьер машины' },
    veh_wheels                   = { label = 'Колёса', description = 'Улучшить колёса машины' },
    veh_neons                    = { label = 'Неон', description = 'Установить неон на машину' },
    veh_xenons                   = { label = 'Ксенон', description = 'Установить ксенон на машину' },
    veh_tint                     = { label = 'Тонировка', description = 'Установить тонировку на машину' },
    veh_plates                   = { label = 'Номера', description = 'Установить номера на машину' },

    -- Medication
    firstaid                     = { label = 'Аптечка', description = 'С помощью аптечки можно поставить людей на ноги' },
    bandage                      = { label = 'Бинт', description = 'Бинт всегда помогает' },
    ifaks                        = { label = 'Аптечка IFAK', description = 'Аптечка для лечения и снятия стресса.' },
    painkillers                  = { label = 'Обезболивающее', description = 'Когда боль уже невыносима — эта таблетка вернёт хорошее самочувствие' },
    walkstick                    = { label = 'Трость', description = 'Трость для всех бабушек и дедушек.. ХА-ХА' },

    -- Communication
    phone                        = { label = 'Телефон', description = 'Симпатичный телефончик' },
    radio                        = { label = 'Рация', description = 'С ней можно общаться по радиосигналу' },
    iphone                       = { label = 'iPhone', description = 'Очень дорогой телефон' },
    samsungphone                 = { label = 'Samsung S10', description = 'Очень дорогой телефон' },
    laptop                       = { label = 'Ноутбук', description = 'Дорогой ноутбук' },
    tablet                       = { label = 'Планшет', description = 'Дорогой планшет' },
    fitbit                       = { label = 'Фитнес-браслет', description = 'Мне нравятся фитнес-браслеты' },
    radioscanner                 = { label = 'Сканер полиции', description = 'С ним можно слушать полицейские переговоры. Но работает не на 100%' },
    pinger                       = { label = 'Пингер', description = 'С пингером и телефоном можно отправить своё местоположение' },
    cryptostick                  = { label = 'Криптофлешка', description = 'Зачем покупать деньги, которых не существует... И сколько на ней может быть..?' },

    -- Theft and jewelry
    rolex                        = { label = 'Золотые часы', description = 'Золотые часы — это же джекпот!' },
    diamond_ring                 = { label = 'Кольцо с бриллиантом', description = 'Кольцо с бриллиантом — это же джекпот!' },
    diamond                      = { label = 'Бриллиант', description = 'Бриллиант — это же джекпот!' },
    goldchain                    = { label = 'Золотая цепь', description = 'Золотая цепь — это же джекпот!' },
    tenkgoldchain                = { label = 'Золотая цепь 10к', description = 'Золотая цепь в 10 карат' },
    goldbar                      = { label = 'Золотой слиток', description = 'Выглядит очень дорого' },

    -- Cop tools
    armor                        = { label = 'Бронежилет', description = 'Немного защиты не помешает... верно?' },
    heavyarmor                   = { label = 'Тяжёлая броня', description = 'Немного защиты не помешает... верно?' },
    handcuffs                    = { label = 'Наручники', description = 'Пригодятся, когда люди плохо себя ведут. А может, и для чего-то ещё?' },
    police_stormram              = { label = 'Таран', description = 'Отличный инструмент, чтобы выбивать двери' },
    empty_evidence_bag           = { label = 'Пустой пакет для улик', description = 'Используется для сбора ДНК с крови, гильз и многого другого' },
    filled_evidence_bag          = { label = 'Пакет с уликами', description = 'Заполненный пакет с уликами, чтобы узнать, кто совершил преступление >:(' },

    -- Fireworks
    firework1                    = { label = '2Brothers', description = 'Фейерверк' },
    firework2                    = { label = 'Poppelers', description = 'Фейерверк' },
    firework3                    = { label = 'WipeOut', description = 'Фейерверк' },
    firework4                    = { label = 'Weeping Willow', description = 'Фейерверк' },

    -- Sea tools
    dendrogyra_coral             = { label = 'Коралл Dendrogyra', description = 'Известен также как столбчатый коралл' },
    antipatharia_coral           = { label = 'Коралл Antipatharia', description = 'Известен также как чёрный коралл' },
    diving_gear                  = { label = 'Снаряжение для дайвинга', description = 'Баллон с кислородом и ребризер' },
    diving_fill                  = { label = 'Баллон с кислородом', description = 'Кислородная трубка и ребризер' },

    -- Other
    casinochips                  = { label = 'Фишки казино', description = 'Фишки для игры в казино' },
    stickynote                   = { label = 'Стикер', description = 'Иногда полезно что-то запомнить :)' },
    moneybag                     = { label = 'Мешок с деньгами', description = 'Мешок с наличными' },
    parachute                    = { label = 'Парашют', description = 'Небо — не предел! Ура!' },
    binoculars                   = { label = 'Бинокль', description = 'Следи за всеми...' },
    lighter                      = { label = 'Зажигалка', description = 'В новогоднюю ночь приятно постоять у огня' },
    certificate                  = { label = 'Сертификат', description = 'Сертификат, подтверждающий владение чем-либо' },
    markedbills                  = { label = 'Меченые деньги', description = 'Деньги?' },
    labkey                       = { label = 'Ключ', description = 'Ключ от какого-то замка...?' },
    printerdocument              = { label = 'Документ', description = 'Какой-то документ' },
    newscam                      = { label = 'Камера для новостей', description = 'Камера для съёмки новостей' },
    newsmic                      = { label = 'Микрофон для новостей', description = 'Микрофон для записи новостей' },
    newsbmic                     = { label = 'Бум-микрофон', description = 'Рабочий бум-микрофон' },

    -- Crafting benches
    item_bench                   = { label = 'Верстак', description = 'Верстак для крафта предметов.' },
    attachment_bench             = { label = 'Верстак для обвесов', description = 'Верстак для крафта обвесов.' },
}

for name, data in pairs(itemOverrides) do
    local item = QBCore.Shared.Items[name]
    if item then
        if data.label then item.label = data.label end
        if data.description then item.description = data.description end
    end
end

-- Новые предметы Brighton Union (ресурсы работ)
local newItems = {
    vegetable = { name = 'vegetable', label = 'Овощи', weight = 500, type = 'item', image = 'vegetable.png', usable = false, shouldClose = false, canRemove = true, description = 'Свежие овощи с фермы' },
    garbage_bag = { name = 'garbage_bag', label = 'Пакет мусора', weight = 500, type = 'item', image = 'garbage_bag.png', usable = false, shouldClose = false, canRemove = true, description = 'Собранный городской мусор' }
}

for name, data in pairs(newItems) do
    if not QBCore.Shared.Items[name] then
        QBCore.Shared.Items[name] = data
    end
end
