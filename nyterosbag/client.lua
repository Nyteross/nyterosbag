ESX = exports["es_extended"]:getSharedObject()

bags = {}
havebag = false

--#############################################################################
--##                            Released By Nyteros                          ##
--#############################################################################

function DepositBag(bag)
    while havebag do
        Citizen.Wait(0)
        ESX.ShowHelpNotification(Config.Translate[Config.Lang].notification.drop_bag)
        if IsControlJustPressed(0, 47) then
            RequestAnimDict("random@domestic") while not HasAnimDictLoaded("random@domestic") do Citizen.Wait(1) end
            TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 8.0, 1.0, 500, 33, 0.0, false, false, false)
            Citizen.Wait(500)
            DetachEntity(bag, true, true)
            PlaceObjectOnGroundProperly(bag)
            DeleteEntity(bag)
            ResetPedMovementClipset(PlayerPedId())
            havebag = false
            x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
            TriggerServerEvent("NyterosBags:CreateBag", {x=x, y=y, z=z-1})
        end
    end
end

function SpawnBag()
    havebag = true
    bag = CreateObject(GetHashKey("ba_prop_battle_bag_01a"), GetEntityCoords(GetPlayerPed(-1)), true, true, false)
    AttachEntityToEntity(bag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.43, 0.0, 0.0, 60.0, 210.0, 100.0, true, true, false, true, 1, true)
    RequestAnimSet("move_m@bag") while not HasAnimSetLoaded("move_m@bag") do Citizen.Wait(1) end 
    SetPedMovementClipset(PlayerPedId(), "move_m@bag", 0.2)
    RemoveAnimSet("move_m@bag")
    DepositBag(bag)
end

function NearBag()
    closest_entity = ESX.Game.GetClosestObject(GetEntityCoords(GetPlayerPed(-1)))

    if #bags >= 1 then
        for k,v in pairs(bags) do
            if closest_entity == NetworkGetEntityFromNetworkId(v.bag) then
                return(true and v)
            elseif GetEntityArchetypeName(closest_entity) == "ba_prop_battle_bag_01a" then
            else
                return(false)
            end
        end
    else
        return(false)
    end
end

function TakeBag(bag)
    havebag = true
    RequestAnimDict("random@domestic") while not HasAnimDictLoaded("random@domestic") do Citizen.Wait(1) end
    TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 8.0, 1.0, 500, 33, 0.0, false, false, false)
    Citizen.Wait(500)
    bagprop = NetworkGetEntityFromNetworkId(bag.bag)
    AttachEntityToEntity(bagprop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.43, 0.0, 0.0, 60.0, 210.0, 100.0, true, true, false, true, 1, true)
    RequestAnimSet("move_m@bag") while not HasAnimSetLoaded("move_m@bag") do Citizen.Wait(1) end 
    SetPedMovementClipset(PlayerPedId(), "move_m@bag", 0.2)
    RemoveAnimSet("move_m@bag")
    while havebag do
        Citizen.Wait(0)
        ESX.ShowHelpNotification(Config.Translate[Config.Lang].notification.drop_bag)
        if IsControlJustPressed(0, 47) then
            RequestAnimDict("random@domestic") while not HasAnimDictLoaded("random@domestic") do Citizen.Wait(1) end
            TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 8.0, 1.0, 500, 33, 0.0, false, false, false)
            Citizen.Wait(500)
            DetachEntity(bagprop, true, true)
            PlaceObjectOnGroundProperly(bagprop)
            ResetPedMovementClipset(PlayerPedId())
            havebag = false
            x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
            TriggerServerEvent("NyterosBags:MoovBag", bag, {x=x, y=y, z=z-1})
        end
    end
end

Citizen.CreateThread(function()
    local timer = 1000
    local nearbag = false
    while true do
        bag = NearBag()
        if not havebag and bag then
            local playerloc = GetEntityCoords(GetPlayerPed(-1))
            local propsloc = GetEntityCoords(NetworkGetEntityFromNetworkId(bag.bag))
            distance = GetDistanceBetweenCoords(propsloc, playerloc, true)		
            nearbag = true
            timer = 1
            if distance <= 1.5 then
                ESX.ShowHelpNotification(Config.Translate[Config.Lang].notification.help_notif)
                if IsControlJustPressed(0, 51) then
                    if nearbag and not havebag then
                        OpenBag(bag)
                    else
                        ShowNotification(Config.Translate[Config.Lang].notification.error)
                    end
                elseif IsControlJustPressed(0,47) then
                    if nearbag and not havebag and not bagmenuisopen then
                        TakeBag(bag)
                    else
                        ShowNotification(Config.Translate[Config.Lang].notification.error)
                    end
                end
                if nearbag and bagmenuisopen  then
                    index.baginfos = bag
                end
            elseif distance > 1.5 and bagmenuisopen then
                RageUI.CloseAll()
            end
        else
            nearbag = false
            timer = 1000
        end
        Citizen.Wait(timer)
    end
    if nearbag then timer = 1 else timer = 1000 end
end)

RegisterCommand("debug_nearbag", function()
    closest_entity = ESX.Game.GetClosestObject(GetEntityCoords(GetPlayerPed(-1)))

    if #bags >= 1 then
        for k,v in pairs(bags) do
            bag = NetworkGetEntityFromNetworkId(v.bag)
            if closest_entity == bag then
                print("Closest Entity: ^3" ..  GetEntityArchetypeName(closest_entity) .. " ^7(id: ^4" .. closest_entity .. "^7), Registered Bag: ^4" .. bag .. "^7, ^2Near a bag^7, Bag DB ID: ^4" .. v.id)
            else
                print("Closest Entity: ^3" ..  GetEntityArchetypeName(closest_entity) .. " ^7(id: ^4" .. closest_entity .. "^7), Registered Bag: ^4" .. bag .. "^7, ^1Not near a bag")
            end
        end
    else
        print("Closest Entity: ^3"  ..  GetEntityArchetypeName(closest_entity) .. " ^7(id: ^4" .. closest_entity .. "^7), ^1Not near a bag")
    end
end,false)

RegisterNetEvent("NyterosBags:Refresh")
AddEventHandler("NyterosBags:Refresh", function(newbags)
    bags = newbags
end)

RegisterCommand("spawn_bag", function()
    SpawnBag()
end,false)

RegisterCommand("debug_respawn", function()
    TriggerServerEvent("NyterosBags:SpawnAllBags")
end,false)

RegisterCommand("debug_delete", function()
    for k,v in pairs(bags) do
        DeleteEntity(NetworkGetEntityFromNetworkId(v.bag))
    end
    bags = {}
end,false)


AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        for k,v in pairs(bags) do
            DeleteEntity(NetworkGetEntityFromNetworkId(v.bag))
        end
    end
end)