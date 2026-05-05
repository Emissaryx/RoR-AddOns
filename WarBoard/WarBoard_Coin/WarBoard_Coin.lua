if not WarBoard_Coin then WarBoard_Coin = {} end
local WarBoard_Coin = WarBoard_Coin
local WindowSetAlpha, WindowSetTintcolor, StatusBarSetMaximumValue, StatusBarSetCurrentValue, Tooltips, GetNumberOfItemsInPocket,
	  LabelSetText, towstring, floor, mod =
	  WindowSetAlpha, WindowSetTintcolor, StatusBarSetMaximumValue, StatusBarSetCurrentValue, Tooltips, GetNumberOfItemsInPocket,
	  LabelSetText, towstring, math.floor, math.mod

function WarBoard_Coin.Initialize()
	if WarBoard.AddMod("WarBoard_Coin") then
		WindowSetAlpha("WarBoard_CoinImageFrame", 0.75)
		WindowSetAlpha("WarBoard_CoinBagsFull", 0)
		WindowSetTintColor("WarBoard_CoinBagsFull", 255, 0, 0)

		RegisterEventHandler(SystemData.Events.PLAYER_MONEY_UPDATED, "WarBoard_Coin.OnPlayerCoinUpdate")
		RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED, "WarBoard_Coin.OnPlayerBagSpaceUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_QUEST_ITEM_SLOT_UPDATED, "WarBoard_Coin.OnPlayerBagSpaceUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "WarBoard_Coin.OnPlayerBagSpaceUpdated")
		WarBoard_Coin.OnPlayerBagSpaceUpdated()
		WarBoard_Coin.OnPlayerCoinUpdate()
	end
end

function WarBoard_Coin.OnPlayerBagSpaceUpdated()
	local pTotal, pMax = WarBoard_Coin.GetBagSpace()
	StatusBarSetMaximumValue("WarBoard_CoinBagBar", pMax)
	StatusBarSetCurrentValue("WarBoard_CoinBagBar", pTotal)
	local red = 0
	local green = 255
	local alpha = 0.5
	if ((pMax - pTotal) <= 9 and (pMax - pTotal) > 5) then
		red = 255 - (((pMax - pTotal) - 5) * 51)
		WindowSetAlpha("WarBoard_CoinBagsFull", 0)
	elseif ((pMax - pTotal) <= 5) then
		red = 255
		green = (pMax - pTotal) * 51
		alpha = 1
		WindowSetAlpha("WarBoard_CoinBagsFull", 0)
	end
	if ((pMax - pTotal) == 0) then
		WindowSetAlpha("WarBoard_CoinBagsFull", 1)
	else
		WindowSetAlpha("WarBoard_CoinBagsFull", 0)
	end
	WindowSetTintColor("WarBoard_CoinBarBackground", red, green, 0)
	WindowSetAlpha("WarBoard_CoinBarBackground", alpha)
end

function WarBoard_Coin.OnMouseOver()
	local pTotal, pMax = WarBoard_Coin.GetBagSpace()
	local pQuests = WarBoard_Coin.GetNumberOfItemsInPocket(EA_Window_Backpack.TYPE_QUEST) --quest items

	Tooltips.CreateTextOnlyTooltip("WarBoard_Coin", nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor("WarBoard_Coin"))
	Tooltips.SetTooltipColor(1, 1, 255, 255, 255)
	Tooltips.SetTooltipText(1, 1, L"Bag Space")
	Tooltips.SetTooltipText(2, 1, L"Total Available Bag Slots: ") 
	Tooltips.SetTooltipText(2, 3, towstring(pMax))
	Tooltips.SetTooltipText(3, 1, L"Filled Bag Slots: ")
	Tooltips.SetTooltipText(3, 3, towstring(pTotal))
	Tooltips.SetTooltipColor(3, 3, 247, 194, 088)
	Tooltips.SetTooltipText(4, 1, L"Open Bag Slots: ")
	Tooltips.SetTooltipText(4, 3, towstring(pMax -pTotal))
	Tooltips.SetTooltipColor(4, 3, 0, 200, 0)
	Tooltips.SetTooltipText(5, 1, L"Quest Items: ")
	Tooltips.SetTooltipText(5, 3, towstring(pQuests))
	Tooltips.Finalize()
end

function WarBoard_Coin.GetBagSpace()
	local playerLevel = GameData.Player.level
	local pTotal = 0 
	local pMax = 32

	pMax = GameData.Player.numBackpackSlots
	pTotal = WarBoard_Coin.GetNumberOfItemsInPocket(EA_Window_Backpack.TYPE_INVENTORY)
	
	return pTotal, pMax
end

function WarBoard_Coin.GetNumberOfItemsInPocket(pocketNumber)
	-- Based on work found in WaaaghBar_BagSpace Version: 0.4 Author: Ben Logan (InfectiousX) Email: roflatroadkill@gmail.com
	local mode
	local itemData
	local count = 0

	local inventory = EA_Window_Backpack.GetItemsFromBackpack(pocketNumber)
	if inventory ~= nil then
		for inventorySlot = 1, EA_Window_Backpack.numberOfSlots[pocketNumber] do
			local itemData = inventory[inventorySlot]
			if EA_Window_Backpack.ValidItem(itemData) then
				count = count + 1
			end
		end
	end

	return count
end

function WarBoard_Coin.OnClick()
	EA_Window_Backpack.ToggleShowing()
end

function WarBoard_Coin.OnPlayerCoinUpdate()
    local curMoney = GameData.Player.money
    local g = floor(curMoney / 10000)
    local s = floor((curMoney - g * 10000) / 100)
    local b = mod(curMoney, 100)

    -- pad gold to 6 digits
    local goldStr = string.format("%06d", g)

    LabelSetText("WarBoard_CoinGold", towstring(goldStr))
    LabelSetText("WarBoard_CoinSilver", towstring(s))
    LabelSetText("WarBoard_CoinBrass",  towstring(b))
end

