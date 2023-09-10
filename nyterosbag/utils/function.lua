function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		return result
	else
		Citizen.Wait(500)
		return nil
	end
end

function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

function CalcWeight()
    finnalweight = 0
    for k,v in pairs(index.baginfos.inventory) do
        finnalweight = finnalweight + v.weight * v.quantity
    end
    return(finnalweight)
end

function GetPlayerInventory()
    ESX.TriggerServerCallback("NyterosBags:getInventory", function(cb)
        index.player_inventory = cb
    end)
end

RegisterNetEvent("NyterosBags:ShowNotification")
AddEventHandler("NyterosBags:ShowNotification", function(text)
    ShowNotification(text)
end)