ESX = exports['es_extended']:getSharedObject()

local currentHeist = nil
local heistBlip = nil
local tabletOpen = false
local isDoingHeist = false
local heistZones = {}

-- Register keybind
RegisterCommand('heist_tablet', function()
    if exports.ox_inventory:GetItemCount('heist_tablet') > 0 then
        OpenHeistTablet()
    end
end, false)

RegisterKeyMapping('heist_tablet', 'Open Heist Tablet', 'keyboard', Config.Keybind)

-- OX Target support for tablet
CreateThread(function()
    exports.ox_target:addGlobalPlayer({
        {
            name = 'use_heist_tablet',
            label = 'Use Heist Tablet',
            icon = 'fa-solid fa-tablet',
            distance = 2.5,
            canInteract = function(entity)
                return exports.ox_inventory:GetItemCount('heist_tablet') > 0
            end,
            onSelect = function()
                OpenHeistTablet()
            end
        }
    })
end)

-- Open tablet
function OpenHeistTablet()
    if tabletOpen or isDoingHeist then return end
    
    tabletOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'openTablet'
    })
    
    ESX.TriggerServerCallback('esx_heist:getContracts', function(contracts)
        SendNUIMessage({
            action = 'setContracts',
            contracts = contracts
        })
    end)
    
    ESX.TriggerServerCallback('esx_heist:getBlackmarketItems', function(items)
        SendNUIMessage({
            action = 'setBlackmarket',
            items = items
        })
    end)
    
    ESX.TriggerServerCallback('esx_heist:getLeaderboard', function(leaderboard)
        SendNUIMessage({
            action = 'setLeaderboard',
            leaderboard = leaderboard
        })
    end)
end

-- NUI Callbacks
RegisterNUICallback('closeTablet', function(data, cb)
    tabletOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startHeist', function(data, cb)
    TriggerServerEvent('esx_heist:startHeist', data.heistId)
    tabletOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellItem', function(data, cb)
    TriggerServerEvent('esx_heist:sellItem', data.item, data.amount)
    Wait(500)
    ESX.TriggerServerCallback('esx_heist:getBlackmarketItems', function(items)
        SendNUIMessage({
            action = 'setBlackmarket',
            items = items
        })
    end)
    cb('ok')
end)

RegisterNUICallback('installApp', function(data, cb)
    TriggerServerEvent('esx_heist:installApp')
    cb('ok')
end)

-- Start heist
RegisterNetEvent('esx_heist:startHeistClient')
AddEventHandler('esx_heist:startHeistClient', function(config, location)
    currentHeist = {
        config = config,
        location = location,
        stage = 1,
        totalStages = #config.stages,
        rewards = {}
    }
    
    isDoingHeist = true
    
    if heistBlip then RemoveBlip(heistBlip) end
    
    heistBlip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
    SetBlipSprite(heistBlip, 161)
    SetBlipDisplay(heistBlip, 4)
    SetBlipScale(heistBlip, 1.2)
    SetBlipColour(heistBlip, 1)
    SetBlipRoute(heistBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(config.name)
    EndTextCommandSetBlipName(heistBlip)
    
    ESX.ShowNotification('~b~Heist Started:~s~ ' .. config.name)
    CreateHeistZone()
end)

-- Create OX Target zone for heist
function CreateHeistZone()
    local location = currentHeist.location.coords
    local stage = currentHeist.config.stages[currentHeist.stage]
    
    -- Remove old zone if exists
    if heistZones[currentHeist.stage - 1] then
        exports.ox_target:removeZone(heistZones[currentHeist.stage - 1])
    end
    
    -- Create sphere zone for heist stage
    heistZones[currentHeist.stage] = exports.ox_target:addSphereZone({
        coords = location,
        radius = 2.0,
        debug = false,
        options = {
            {
                name = 'heist_stage_' .. currentHeist.stage,
                label = stage.name,
                icon = 'fa-solid fa-user-secret',
                distance = 2.5,
                onSelect = function()
                    DoHeistStage(stage)
                end,
                canInteract = function()
                    return currentHeist and currentHeist.stage <= currentHeist.totalStages and not isDoingHeist
                end
            }
        }
    })
    
    isDoingHeist = false
end

-- Do heist stage with OX Target
function DoHeistStage(stage)
    if isDoingHeist then return end
    
    isDoingHeist = true
    local playerPed = PlayerPedId()
    
    -- Load animation
    if Config.Animations[stage.type] then
        local anim = Config.Animations[stage.type]
        RequestAnimDict(anim.dict)
        while not HasAnimDictLoaded(anim.dict) do
            Wait(100)
        end
        TaskPlayAnim(playerPed, anim.dict, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
    end
    
    -- Show minigame based on type
    local success = false
    
    if stage.type == 'hack' then
        success = StartHackMinigame()
    elseif stage.type == 'drill' then
        success = StartDrillMinigame(stage.duration)
    elseif stage.type == 'thermite' then
        success = StartThermiteMinigame()
    elseif stage.type == 'lockpick' then
        success = StartLockpickMinigame()
    else
        -- Default progress bar
        success = StartProgressBar(stage.name, stage.duration)
    end
    
    ClearPedTasks(playerPed)
    
    if success then
        -- Collect rewards
        if stage.reward then
            for _, reward in ipairs(stage.reward) do
                table.insert(currentHeist.rewards, reward)
            end
        end
        
        -- Remove old zone
        if heistZones[currentHeist.stage] then
            exports.ox_target:removeZone(heistZones[currentHeist.stage])
        end
        
        currentHeist.stage = currentHeist.stage + 1
        
        if currentHeist.stage > currentHeist.totalStages then
            CompleteHeist(true)
        else
            ESX.ShowNotification('~g~Stage Complete:~s~ ' .. (currentHeist.stage - 1) .. '/' .. currentHeist.totalStages)
            CreateHeistZone() -- Create next stage zone
        end
    else
        CompleteHeist(false)
    end
end

-- Progress bar
function StartProgressBar(label, duration)
    if Config.UseProgressBar then
        local finished = false
        local success = true
        
        exports['progressbar']:Progress({
            name = "heist_stage",
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(cancelled)
            success = not cancelled
            finished = true
        end)
        
        while not finished do
            Wait(100)
        end
        return success
    else
        Wait(duration)
        return true
    end
end

-- Hack minigame
function StartHackMinigame()
    ESX.ShowNotification('~b~Hacking...~s~ Match the sequence!')
    
    local sequence = {}
    local playerSequence = {}
    local sequenceLength = 4
    
    -- Generate sequence
    for i = 1, sequenceLength do
        table.insert(sequence, math.random(1, 4))
    end
    
    -- Show sequence
    for _, num in ipairs(sequence) do
        ESX.ShowNotification('~y~' .. num)
        Wait(1000)
    end
    
    ESX.ShowNotification('~g~Now enter the sequence!')
    
    -- Player input
    local timeout = GetGameTimer() + 10000
    while #playerSequence < sequenceLength and GetGameTimer() < timeout do
        if IsControlJustPressed(0, 172) then
            table.insert(playerSequence, 1)
            ESX.ShowNotification('~b~Input: 1')
        elseif IsControlJustPressed(0, 173) then
            table.insert(playerSequence, 2)
            ESX.ShowNotification('~b~Input: 2')
        elseif IsControlJustPressed(0, 174) then
            table.insert(playerSequence, 3)
            ESX.ShowNotification('~b~Input: 3')
        elseif IsControlJustPressed(0, 175) then
            table.insert(playerSequence, 4)
            ESX.ShowNotification('~b~Input: 4')
        end
        Wait(0)
    end
    
    -- Check if correct
    for i = 1, sequenceLength do
        if sequence[i] ~= playerSequence[i] then
            ESX.ShowNotification('~r~Hack Failed!')
            return false
        end
    end
    
    ESX.ShowNotification('~g~Hack Successful!')
    return true
end

-- Drill minigame
function StartDrillMinigame(duration)
    ESX.ShowNotification('~b~Drilling...~s~ Keep steady!')
    
    local success = true
    local endTime = GetGameTimer() + duration
    local difficulty = 0.5
    
    while GetGameTimer() < endTime do
        local input = 0
        
        if IsControlPressed(0, 172) then input = input + 1 end
        if IsControlPressed(0, 173) then input = input - 1 end
        
        local shake = math.random(-10, 10) / 10
        
        if math.abs(input - shake) > difficulty then
            ESX.ShowNotification('~r~Drill slipped!')
            success = false
            break
        end
        
        local progress = math.floor((1 - (endTime - GetGameTimer()) / duration) * 100)
        DrawText2D(0.5, 0.5, 'Drilling: ' .. progress .. '%', 0.7)
        Wait(0)
    end
    
    if success then
        ESX.ShowNotification('~g~Drill Complete!')
    end
    
    return success
end

-- Thermite minigame
function StartThermiteMinigame()
    ESX.ShowNotification('~b~Planting Thermite...~s~ Hit the marks!')
    
    local hits = 0
    local required = 5
    local timeout = GetGameTimer() + 10000
    
    while hits < required and GetGameTimer() < timeout do
        local target = math.random(1, 4)
        
        local keyNames = {'UP', 'DOWN', 'LEFT', 'RIGHT'}
        ESX.ShowNotification('~y~Press: ' .. keyNames[target])
        
        Wait(1500)
        
        local pressed = 0
        if IsControlJustPressed(0, 172) then pressed = 1 end
        if IsControlJustPressed(0, 173) then pressed = 2 end
        if IsControlJustPressed(0, 174) then pressed = 3 end
        if IsControlJustPressed(0, 175) then pressed = 4 end
        
        if pressed == target then
            hits = hits + 1
            ESX.ShowNotification('~g~Hit! ' .. hits .. '/' .. required)
        elseif pressed ~= 0 then
            ESX.ShowNotification('~r~Miss!')
            return false
        end
        
        Wait(500)
    end
    
    if hits >= required then
        ESX.ShowNotification('~g~Thermite Planted!')
        return true
    end
    
    return false
end

-- Lockpick minigame
function StartLockpickMinigame()
    ESX.ShowNotification('~b~Lockpicking...~s~ Find the sweet spot!')
    
    local sweetSpot = math.random(1, 10)
    local attempts = 3
    
    while attempts > 0 do
        local guess = math.random(1, 10)
        
        Wait(2000)
        
        if guess == sweetSpot then
            ESX.ShowNotification('~g~Lock Picked!')
            return true
        else
            attempts = attempts - 1
            if guess < sweetSpot then
                ESX.ShowNotification('~y~Higher... Attempts: ' .. attempts)
            else
                ESX.ShowNotification('~y~Lower... Attempts: ' .. attempts)
            end
        end
    end
    
    ESX.ShowNotification('~r~Lockpick Broke!')
    return false
end

-- Complete heist
function CompleteHeist(success)
    TriggerServerEvent('esx_heist:completeHeist', success, currentHeist.rewards)
    
    if heistBlip then
        RemoveBlip(heistBlip)
        heistBlip = nil
    end
    
    -- Remove all zones
    for _, zoneId in pairs(heistZones) do
        exports.ox_target:removeZone(zoneId)
    end
    heistZones = {}
    
    currentHeist = nil
    isDoingHeist = false
end

-- Police alert
RegisterNetEvent('esx_heist:policeAlert')
AddEventHandler('esx_heist:policeAlert', function(coords, heistName)
    local playerData = ESX.GetPlayerData()
    
    for _, job in pairs(Config.PoliceJobs) do
        if playerData.job.name == job then
            ESX.ShowNotification('~r~[ALERT]~s~ ' .. heistName .. ' in progress!')
            
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 161)
            SetBlipScale(blip, 1.5)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Heist Alert: ' .. heistName)
            EndTextCommandSetBlipName(blip)
            
            SetTimeout(60000, function()
                RemoveBlip(blip)
            end)
            
            break
        end
    end
end)

-- Draw 2D Text
function DrawText2D(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- ESC to close tablet
CreateThread(function()
    while true do
        Wait(0)
        if tabletOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 106, true)
        end
    end
end)
