bagmenuisopen = false

index = {
    actions = {
        Config.Translate[Config.Lang].menu.take, 
        Config.Translate[Config.Lang].menu.deposit
    },
    index_actions = 1,
    baginfos = {},
    player_inventory = {}
}

function OpenBag()
	if bagmenuisopen then return end
    GetPlayerInventory()
	RMenu.Add("bag", "main", RageUI.CreateMenu(Config.Translate[Config.Lang].menu.title, Config.Translate[Config.Lang].menu.title))
	RageUI.Visible(RMenu:Get("bag", "main"), true)
	bagmenuisopen = true
	Citizen.CreateThread(function()
		while bagmenuisopen do

			local bagmenucanbeclose = true
			RageUI.IsVisible(RMenu:Get("bag", "main"), true, true, true, function()
			bagmenucanbeclose = false

            RageUI.Separator(Config.Translate[Config.Lang].menu.weight .. CalcWeight() .. "~s~/~y~50~s~kg")

            RageUI.List(Config.Translate[Config.Lang].menu.action, index.actions, index.index_actions or 1, nil, {}, true, function(Hovered, Active, Selected, Index) 
                index.index_actions = Index; 
            end)
            
            RageUI.Line()

            if index.index_actions == 1 then
                for k,v in pairs(index.player_inventory) do
                    if v.count >= 1 then
                        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~y~x" .. v.count.. " ~s~(~y~" .. v.count * v.weight .. " ~s~kg)"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                local quantity = KeyboardInput(Config.Translate[Config.Lang].misc.quantity, Config.Translate[Config.Lang].misc.quantity, "", 2)
                                quantity = tonumber(quantity)
                                if quantity ~= nil and quantity > 0 and quantity ~= "" and quantity ~= " " and quatity ~= "  " then
                                    TriggerServerEvent("NyterosBags:Deposit", index.baginfos, v.name, quantity, CalcWeight())
                                    GetPlayerInventory()
                                else
                                    ShowNotification(Config.Translate[Config.Lang].notification.invalid_quantity)
                                end
                            end
                        end)
                    end
                end
            else
                for k,v in pairs(index.baginfos.inventory) do
                    if v.quantity >= 1 then
                        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~y~x" .. v.quantity.. " ~s~(~y~" .. v.quantity * v.weight .. " ~s~kg)"}, true, function(Hovered, Active, Selected)
                            if Selected then
                                local quantity = KeyboardInput(Config.Translate[Config.Lang].misc.quantity, Config.Translate[Config.Lang].misc.quantity, "", 2)
                                quantity = tonumber(quantity)
                                if quantity ~= nil and quantity > 0 and quantity ~= "" and quantity ~= " " and quatity ~= "  " then
                                    TriggerServerEvent("NyterosBags:Take", index.baginfos, v.name, quantity)
                                    GetPlayerInventory()
                                else
                                    ShowNotification(Config.Translate[Config.Lang].notification.invalid_quantity)
                                end
                            end
                        end)
                    end
                end
            end

			end,function()
			end,1)

			if bagmenucanbeclose and bagmenuisopen then
				bagmenuisopen = false
			end
			Citizen.Wait(0)
		end
		RMenu:Delete("bag", "main")
	end)
end