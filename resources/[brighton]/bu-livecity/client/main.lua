local peds = {}

local function clearFar()
    local ped = PlayerPedId()
    local pPos = GetEntityCoords(ped)
    for i = #peds, 1, -1 do
        local p = peds[i]
        if not DoesEntityExist(p) or #(GetEntityCoords(p) - pPos) > Config.DespawnDistance then
            if DoesEntityExist(p) then DeleteEntity(p) end
            table.remove(peds, i)
        end
    end
end

local function spawnOne()
    local ped = PlayerPedId()
    local pPos = GetEntityCoords(ped)
    local angle = math.random() * math.pi * 2
    local dist = math.random(30, Config.SpawnRadius)
    local x = pPos.x + math.cos(angle) * dist
    local y = pPos.y + math.sin(angle) * dist
    local found, z = GetGroundZFor_3dCoord(x, y, pPos.z + 5.0, false)
    if not found then return end

    local model = Config.Models[math.random(1, #Config.Models)]
    RequestModel(model)
    if not HasModelLoaded(model) then return end

    local entity = CreatePed(4, model, x, y, z, math.random() * 360, false, false)
    SetBlockingOfNonTemporaryEvents(entity, true)
    if math.random() < 0.5 then
        TaskWanderStandard(entity, 10.0, 20.0)
    else
        TaskStartScenarioInPlace(entity, Config.Scenarios[math.random(1, #Config.Scenarios)], -1, true)
    end
    peds[#peds + 1] = entity
end

CreateThread(function()
    while true do
        Wait(Config.SpawnInterval)
        if LocalPlayer.state.isLoggedIn then
            clearFar()
            if #peds < Config.MaxPeds then
                spawnOne()
            end
        end
    end
end)
