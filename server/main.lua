ESX = exports['es_extended']:getSharedObject()

local activeHeists = {}
local cooldowns = {}

-- Check police count
function GetPoliceCount()
    local count = 0
    local players = ESX.GetExtendedPlayers()
    
    for _, xPlayer in pairs(players) do
        for _, job in pairs(Config.PoliceJobs) do
            if xPlayer.job.name == job then
                count = count + 1
                break
            end
        end
    end
    
    return count
end

-- Get leaderboard
ESX.RegisterServerCallback('esx_heist:getLeaderboard', function(source, cb)
    MySQL.query('SELECT identifier, total_heists, total_earned FROM heist_stats ORDER BY total_earned DESC LIMIT 10', {}, function(result)
        cb(result or {})
    end)
end)

-- Get available contracts
ESX.RegisterServerCallback('esx_heist:getContracts', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local availableContracts = {}
    
    for heistId, heist in pairs(Config.Heists) do
        local canStart = true
        local cooldownRemaining = 0
        
        if cooldowns[heistId] and cooldowns[heistId] > os.time() then
            canStart = false
            cooldownRemaining = cooldowns[heistId] - os.time()
        end
        
        local hasItems = true
        local missingItems = {}
        for _, item in ipairs(heist.requiredItems) do
            local itemCount = exports.ox_inventory:GetItemCount(source, item)
            if itemCount < 1 then
                hasItems = false
                table.insert(missingItems, item)
            end
        end
        
        table.insert(availableContracts, {
            id = heistId,
            name = heist.name,
            description = heist.description,
            difficulty = heist.difficulty,
            icon = heist.icon,
            minPlayers = heist.minPlayers,
            maxPlayers = heist.maxPlayers,
            payout = heist.payout,
            requiredItems = heist.requiredItems,
            canStart = canStart,
            hasItems = hasItems,
            missingItems = missingItems,
            cooldownRemaining = cooldownRemaining,
            stages = #heist.stages
        })
    end
    
    cb(availableContracts)
end)

-- Get blackmarket items
ESX.RegisterServerCallback('esx_heist:getBlackmarketItems', function(source, cb)
    local items = {}
    
    for _, item in ipairs(Config.BlackmarketItems) do
        local count = exports.ox_inventory:GetItemCount(source, item.item)
        if count > 0 then
            table.insert(items, {
                item = item.item,
                label = item.label,
                price = item.price,
                count = count,
                totalValue = item.price * count
            })
        end
    end
    
    cb(items)
end)

-- Sell item
RegisterServerEvent('esx_heist:sellItem')
AddEventHandler('esx_heist:sellItem', function(itemName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    for _, item in ipairs(Config.BlackmarketItems) do
        if item.item == itemName then
            local count = exports.ox_inventory:GetItemCount(_source, itemName)
            
            if count >= amount then
                if exports.ox_inventory:RemoveItem(_source, itemName, amount) then
                    local payment = item.price * amount
                    xPlayer.addMoney(payment)
                    TriggerClientEvent('esx:showNotification', _source, 'Sold ' .. amount .. 'x ' .. item.label .. ' for  .. payment)
                end
            end
            break
        end
    end
end)

-- Start heist
RegisterServerEvent('esx_heist:startHeist')
AddEventHandler('esx_heist:startHeist', function(heistId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    local heistConfig = Config.Heists[heistId]
    if not heistConfig then return end
    
    -- Check police
    if GetPoliceCount() < Config.MinPolice then
        TriggerClientEvent('esx:showNotification', _source, 'Not enough police online')
        return
    end
    
    -- Check cooldown
    if cooldowns[heistId] and cooldowns[heistId] > os.time() then
        TriggerClientEvent('esx:showNotification', _source, 'This heist is on cooldown')
        return
    end
    
    -- Check items
    for _, item in ipairs(heistConfig.requiredItems) do
        local count = exports.ox_inventory:GetItemCount(_source, item)
        if count < 1 then
            TriggerClientEvent('esx:showNotification', _source, 'Missing: ' .. item)
            return
        end
    end
    
    -- Remove items
    for _, item in ipairs(heistConfig.requiredItems) do
        exports.ox_inventory:RemoveItem(_source, item, 1)
    end
    
    -- Select location
    local location = heistConfig.locations[math.random(#heistConfig.locations)]
    
    activeHeists[_source] = {
        heistId = heistId,
        config = heistConfig,
        location = location,
        startTime = os.time(),
        stage = 1
    }
    
    -- Alert police
    TriggerClientEvent('esx_heist:policeAlert', -1, location.coords, heistConfig.name)
    
    TriggerClientEvent('esx_heist:startHeistClient', _source, heistConfig, location)
end)

-- Complete heist
RegisterServerEvent('esx_heist:completeHeist')
AddEventHandler('esx_heist:completeHeist', function(success, rewards)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not activeHeists[_source] then return end
    
    local heistData = activeHeists[_source]
    local config = heistData.config
    
    if success then
        local payout = math.random(config.payout.min, config.payout.max)
        xPlayer.addMoney(payout)
        
        -- Give rewards
        if rewards then
            for _, reward in ipairs(rewards) do
                local amount = math.random(1, 3)
                exports.ox_inventory:AddItem(_source, reward, amount)
            end
        end
        
        -- Update stats
        MySQL.insert('INSERT INTO heist_stats (identifier, total_heists, total_earned) VALUES (?, 1, ?) ON DUPLICATE KEY UPDATE total_heists = total_heists + 1, total_earned = total_earned + ?', {
            xPlayer.identifier, payout, payout
        })
        
        TriggerClientEvent('esx:showNotification', _source, '~g~Heist Complete!~s~ + .. payout)
        cooldowns[heistData.heistId] = os.time() + config.cooldown
    else
        TriggerClientEvent('esx:showNotification', _source, '~r~Heist Failed!')
    end
    
    activeHeists[_source] = nil
end)

-- Install heist app
RegisterServerEvent('esx_heist:installApp')
AddEventHandler('esx_heist:installApp', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    local hasPendrive = exports.ox_inventory:GetItemCount(_source, 'hacker_pendrive')
    
    if hasPendrive > 0 then
        exports.ox_inventory:RemoveItem(_source, 'hacker_pendrive', 1)
        TriggerClientEvent('esx:showNotification', _source, '~g~Heist App Installed!~s~ Check your phone')
    else
        TriggerClientEvent('esx:showNotification', _source, '~r~Need Hacker Pendrive!')
    end
end)
