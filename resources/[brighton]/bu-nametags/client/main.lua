local tags = {}

RegisterNetEvent('bu-nametags:client:update', function(list)
    tags = {}
    for _, entry in ipairs(list) do
        tags[entry.id] = entry
    end
end)

local function drawText3D(coords, text)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(0.33, 0.33)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(233, 238, 243, 235)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

CreateThread(function()
    while true do
        local wait = 250
        if LocalPlayer.state.isLoggedIn and not LocalPlayer.state.buSelecting then
            local myPed = PlayerPedId()
            local myPos = GetEntityCoords(myPed)
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if ped ~= myPed and DoesEntityExist(ped) then
                    local entry = tags[GetPlayerServerId(player)]
                    if entry then
                        local pedPos = GetEntityCoords(ped)
                        if #(myPos - pedPos) < Config.DrawDistance then
                            wait = 0
                            local label
                            if entry.name then
                                label = entry.name .. ' (' .. entry.id .. ')'
                            else
                                label = (entry.gender == 1 and 'Гражданка' or 'Гражданин') .. ' (' .. entry.id .. ')'
                            end
                            drawText3D(vector3(pedPos.x, pedPos.y, pedPos.z + 1.1), label)
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)
