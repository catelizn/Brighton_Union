Config = Config or {}

Config.Items = {
    { id = 'sit',    label = 'Присесть',  icon = '🪑' },
    { id = 'point',  label = 'Указать',   icon = '👉' },
    { id = 'salute', label = 'Честь',     icon = '✋' },
    { id = 'pray',   label = 'Молиться',  icon = '🙏' },
    { id = 'wave',   label = 'Махать',    icon = '👋' },
    { id = 'drink',  label = 'Пить',      icon = '🍺' },
    { id = 'smoke',  label = 'Курить',    icon = '🚬' },
    { id = 'lean',   label = 'Обо что-то' , icon = '🕴️' }
}

Config.Actions = {
    sit    = { scenario = 'WORLD_HUMAN_SIT' },
    point  = { anim = { dict = 'anim@mp_point', name = 'scenario_point', flag = 49 } },
    salute = { anim = { dict = 'anim@mp_player_intcelebrationmale@salute', name = 'salute', flag = 49 } },
    pray   = { anim = { dict = 'anim@mp_player_intcelebrationmale@pray', name = 'pray', flag = 49 } },
    wave   = { anim = { dict = 'anim@mp_player_intcelebrationmale@wave', name = 'wave', flag = 49 } },
    drink  = { anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', name = 'idle_a', flag = 49 } },
    smoke  = { anim = { dict = 'amb@world_human_smoking@male@idle_a', name = 'idle_a', flag = 49 } },
    lean   = { scenario = 'WORLD_HUMAN_LEANING' }
}
