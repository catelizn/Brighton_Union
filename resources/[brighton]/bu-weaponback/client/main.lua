-- Оружие на теле: пропы винтовок/дробовиков за спиной и пистолетов/SMG в
-- кобуре. Проп виден, когда оружие не в руках, и прячется при доставании.

local props = {} -- weaponName -> { entity, bone }

local function ensureProp(entry)
    if props[entry.weapon] then return props[entry.weapon] end

    local model = entry.prop
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = PlayerPedId()
    local entity = CreateObject(joaat(model), 0.0, 0.0, 0.0, true, true, false)
    SetEntityCollision(entity, false, false)
    SetEntityVisible(entity, false, false)
    SetEntityAsMissionEntity(entity, true, true)

    local boneIndex = GetPedBoneIndex(ped, Config.Bones[entry.bone])
    AttachEntityToEntity(entity, ped, boneIndex, entry.offset.x, entry.offset.y, entry.offset.z,
        entry.rot.x, entry.rot.y, entry.rot.z, false, false, false, false, 2, true)

    props[entry.weapon] = { entity = entity, bone = boneIndex }
    return props[entry.weapon]
end

CreateThread(function()
    while true do
        Wait(400)
        local ped = PlayerPedId()
        if not LocalPlayer.state.isLoggedIn then
            for _, data in pairs(props) do
                SetEntityVisible(data.entity, false, false)
            end
            goto continue
        end

        local selected = GetSelectedPedWeapon(ped)

        for _, entry in ipairs(Config.Weapons) do
            local hash = joaat(entry.weapon)
            if HasPedGotWeapon(ped, hash, false) then
                local data = ensureProp(entry)
                SetEntityVisible(data.entity, selected ~= hash, false)
            end
        end

        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, data in pairs(props) do
        if DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
        end
    end
    props = {}
end)
