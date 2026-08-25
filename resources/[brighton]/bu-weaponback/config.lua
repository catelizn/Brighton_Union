Config = Config or {}

-- Большое оружие видно на теле, как в RedAge/Majestic: винтовки и дробовики
-- за спиной, пистолеты и SMG в кобуре на бедре. Проп показывается, когда
-- оружие не в руках, и прячется при доставании.
-- Оффсеты и кости взяты из проп-реестра RedAge (attachments addWeapons).

Config.Bones = {
    back = 24818,   -- SKEL_Spine2
    thigh = 51826   -- SKEL_R_Thigh
}

Config.Weapons = {
    -- Пистолеты: кобура на правом бедре
    { weapon = 'WEAPON_PISTOL',        prop = 'w_pi_pistol',          bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_COMBATPISTOL',  prop = 'w_pi_combatpistol',    bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_APPISTOL',      prop = 'w_pi_appistol',        bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_HEAVYPISTOL',   prop = 'w_pi_heavypistol',     bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_PISTOL50',      prop = 'w_pi_pistol50',        bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_SNSPISTOL',     prop = 'w_pi_sns_pistol',      bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    { weapon = 'WEAPON_VINTAGEPISTOL', prop = 'w_pi_vintage_pistol',  bone = 'thigh', offset = vector3(0.02, 0.06, 0.10),  rot = vector3(-100.0, 0.0, 0.0) },
    -- SMG: кобура на левом бедре
    { weapon = 'WEAPON_MICROSMG',      prop = 'w_sb_microsmg',        bone = 'thigh', offset = vector3(0.08, 0.03, -0.10), rot = vector3(-80.77, 0.0, 0.0) },
    { weapon = 'WEAPON_SMG',           prop = 'w_sb_smg',             bone = 'thigh', offset = vector3(0.08, 0.03, -0.10), rot = vector3(-80.77, 0.0, 0.0) },
    { weapon = 'WEAPON_ASSAULTSMG',    prop = 'w_sb_assaultsmg',      bone = 'thigh', offset = vector3(0.08, 0.03, -0.10), rot = vector3(-80.77, 0.0, 0.0) },
    { weapon = 'WEAPON_COMBATPDW',     prop = 'w_sb_pdw',             bone = 'thigh', offset = vector3(0.08, 0.03, -0.10), rot = vector3(-80.77, 0.0, 0.0) },
    -- Винтовки: за спиной
    { weapon = 'WEAPON_ASSAULTRIFLE',  prop = 'w_ar_assaultrifle',    bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_CARBINERIFLE',  prop = 'w_ar_carbinerifle',    bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_SPECIALCARBINE',prop = 'w_ar_specialcarbine',  bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_BULLPUPRIFLE',  prop = 'w_ar_bullpuprifle',    bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_ADVANCEDRIFLE', prop = 'w_ar_advancedrifle',   bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_COMPACTRIFLE',  prop = 'w_ar_compactrifle',    bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_MG',            prop = 'w_mg_mg',              bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    { weapon = 'WEAPON_COMBATMG',      prop = 'w_mg_combatmg',        bone = 'back', offset = vector3(-0.10, -0.15, 0.11),  rot = vector3(-180.0, 0.0, 0.0) },
    -- Дробовики: за спиной, чуть ниже
    { weapon = 'WEAPON_PUMPSHOTGUN',   prop = 'w_sg_pumpshotgun',     bone = 'back', offset = vector3(-0.10, -0.15, -0.13), rot = vector3(0.0, 0.0, 3.5) },
    { weapon = 'WEAPON_ASSAULTSHOTGUN',prop = 'w_sg_assaultshotgun',  bone = 'back', offset = vector3(-0.10, -0.15, -0.13), rot = vector3(0.0, 0.0, 3.5) },
    { weapon = 'WEAPON_BULLPUPSHOTGUN',prop = 'w_sg_bullpupshotgun',  bone = 'back', offset = vector3(-0.10, -0.15, -0.13), rot = vector3(0.0, 0.0, 3.5) },
    { weapon = 'WEAPON_HEAVYSHOTGUN',  prop = 'w_sg_heavyshotgun',    bone = 'back', offset = vector3(-0.10, -0.15, -0.13), rot = vector3(0.0, 0.0, 3.5) },
    { weapon = 'WEAPON_SAWNOFFSHOTGUN',prop = 'w_sg_sawnoff',         bone = 'back', offset = vector3(-0.10, -0.15, -0.13), rot = vector3(0.0, 0.0, 3.5) }
}
