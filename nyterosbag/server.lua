ESX = exports["es_extended"]:getSharedObject()

bags = {}

RegisterServerEvent("NyterosBags:CreateBag")
AddEventHandler("NyterosBags:CreateBag", function(coords)
    MySQL.Async.execute("INSERT INTO bags (pos, inventory) VALUES (@pos, @inventory)", {
        ["@pos"] = json.encode(coords),
        ["@inventory"] = json.encode({}),
    }, function()
        MySQL.Async.fetchAll("SELECT * FROM bags", {
        }, function(result)
            id = nil
            for k,v in pairs(result) do 
                id = v.id
            end
            bag = CreateObject(GetHashKey("ba_prop_battle_bag_01a"), coords.x, coords.y, coords.z, true, true, false)
            while not DoesEntityExist(bag) do Citizen.Wait(1) end
            FreezeEntityPosition(bag, true)
            table.insert(bags, {
                id = id,
                bag = NetworkGetNetworkIdFromEntity(bag),
                coords = coords,
                inventory = {},
            })
            TriggerClientEvent("NyterosBags:Refresh", -1, bags)
        end)
    end)
end)

RegisterServerEvent("NyterosBags:MoovBag")
AddEventHandler("NyterosBags:MoovBag", function(bag, coords)
    MySQL.Async.execute("UPDATE bags SET pos = @pos WHERE id = @id", {
        ["@pos"] = json.encode(coords),
        ["id"] = bag.id,
    }, function()
        SetEntityCoords(bag.bag, coords.x, coords.y, coords.z, false, false, false, false)
        FreezeEntityPosition(bag.bag, true)
        for k,v in pairs(bags) do
            if v.id == bag.id then
                v.coords = coords
            end
        end
        TriggerClientEvent("NyterosBags:Refresh", -1, bags)
    end)
end)

RegisterServerEvent("NyterosBags:SpawnAllBags")
AddEventHandler("NyterosBags:SpawnAllBags", function()
    bags = {}
    MySQL.Async.fetchAll("SELECT * FROM bags", {
    }, function(result)
        for k,v in pairs(result) do
            coords = json.decode(v.pos)
            bag = CreateObject(GetHashKey("ba_prop_battle_bag_01a"), coords.x, coords.y, coords.z, true, true, false)
            FreezeEntityPosition(bag, true)
            while not DoesEntityExist(bag) do Citizen.Wait(1) end
            table.insert(bags, {
                id = v.id,
                bag = NetworkGetNetworkIdFromEntity(bag),
                coords = coords,
                inventory = json.decode(v.inventory),
            })
        end
        TriggerClientEvent("NyterosBags:Refresh", -1, bags)
    end)
end)

RegisterServerEvent("NyterosBags:Deposit")
AddEventHandler("NyterosBags:Deposit", function(baginfo, item, quantity, weight)
    local inventory = baginfo.inventory
    local objetname = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem(item).count >= quantity then
        if weight + quantity <= 50 then
            for k,v in pairs(inventory) do
                if v.name == item then
                    objetname = item
                end
            end
            if objetname == item then
                for k,v in pairs(inventory) do
                    if objetname == v.name then
                        baginfo.inventory[k].quantity = v.quantity + quantity
                    end
                end
            else
                table.insert(inventory, {name = item, label = xPlayer.getInventoryItem(item).label, quantity = quantity, weight = xPlayer.getInventoryItem(item).weight})
            end
            MySQL.Async.execute("UPDATE bags SET inventory = @inventory WHERE id = @id", {
                ["@inventory"] = json.encode(inventory),
                ["@id"] = baginfo.id
            }, function() end)
            for k,v in pairs(bags) do
                if v.id == baginfo.id then
                    bags[k].inventory = inventory
                end
            end
            TriggerClientEvent("NyterosBags:Refresh", -1, bags)
            xPlayer.removeInventoryItem(item, quantity)
            TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.deposit .. quantity .. " ~b~" .. xPlayer.getInventoryItem(item).label)
        else
            TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.insuffisant_space)
        end
    else
        TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.not_enough .. xPlayer.getInventoryItem(item).label)
    end
end)

RegisterServerEvent("NyterosBags:Take")
AddEventHandler("NyterosBags:Take", function(baginfo, item, quantity)
    local inventory = baginfo.inventory
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(inventory) do
        if v.name == item then
            if v.quantity >= quantity and quantity > 0 then
                if xPlayer.canCarryItem(item, quantity) then
                    v.quantity = v.quantity - quantity
                    MySQL.Async.execute("UPDATE bags SET inventory = @inventory WHERE id = @id", {
                        ["@inventory"] = json.encode(inventory),
                        ["@id"] = baginfo.id
                    }, function() end)
                    for k,v in pairs(bags) do
                        if v.id == baginfo.id then
                            bags[k].inventory = inventory
                        end
                    end
                    TriggerClientEvent("NyterosBags:Refresh", -1, bags)
                    xPlayer.addInventoryItem(item, quantity)
                    TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.take .. quantity .. " ~b~" .. xPlayer.getInventoryItem(item).label)
                else
                    TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.cant_take .. quantity  .. xPlayer.getInventoryItem(item).label)
                end
            else
                TriggerClientEvent("NyterosBags:ShowNotification", source, Config.Translate[Config.Lang].notification.not_enough .. xPlayer.getInventoryItem(item).label .. Config.Translate[Config.Lang].notification.in_bag)
            end
        end
    end
end)

ESX.RegisterServerCallback("NyterosBags:getInventory", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getInventory())
end)