GMT2.GetInventory = {}
GMT2.GetInventory.Players = {}

function GMT2.GetInventory.List(Table)
local Splitted_Table = StringSplit(tostring(Table), ":")
local Char_Name = Splitted_Table[2]
local Money = tonumber(Splitted_Table[3])

local WindowName = "GetInventory_"..Char_Name.."_"	
if DoesWindowExist(WindowName) == false then CreateWindowFromTemplate(WindowName,"GetInventoryWindow", "Root") end
local Char_Name_Link = towstring(CreateHyperLink(L"PLAYER:"..towstring(Char_Name),towstring(Char_Name), {100,100,255}, {} ))
LabelSetText(WindowName.."Name",L"GMT2 GetInventory")
LabelSetText(WindowName.."Item1Title",L"Character:")
LabelSetText(WindowName.."Item1Text",Char_Name_Link)
WindowSetShowing(WindowName.."Item1EditBox",false)
MoneyFrame.FormatMoney (WindowName.."Money", Money, MoneyFrame.SHOW_EMPTY_WINDOWS)

	local texture, x, y, disabledTexture = GetIconData(4671)
	DynamicImageSetTexture(WindowName.."UpdateIcon",texture, 64, 64)	

GMT2.GetInventory.Players[Char_Name] = {Profile={},Inventory={},Currency={},Crafting={},Quest={},Bank_1={},Bank_2={},Bank_3={},SelectedTab = 1}
	for k,v in pairs(Splitted_Table) do
	local Splitted_Data = StringSplit(tostring(v), ",")
		if Splitted_Data[3] ~= nil then
			if tonumber(Splitted_Data[1]) >= 40 and tonumber(Splitted_Data[1]) <= 119 then
				local InventorySlot = tonumber(Splitted_Data[1])-39
				GMT2.GetInventory.Players[Char_Name].Inventory[InventorySlot] = nil
				GMT2.GetInventory.Players[Char_Name].Inventory[InventorySlot] = {Slot=InventorySlot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}
				
			elseif tonumber(Splitted_Data[1]) >= 500 and tonumber(Splitted_Data[1]) <= 531 then
				local CurrencySlot = tonumber(Splitted_Data[1])-499
				GMT2.GetInventory.Players[Char_Name].Currency[CurrencySlot] = nil				
				GMT2.GetInventory.Players[Char_Name].Currency[CurrencySlot] = {Slot=CurrencySlot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}
			elseif tonumber(Splitted_Data[1]) >= 400 and tonumber(Splitted_Data[1]) <= 480 then
				local CraftingSlot = tonumber(Splitted_Data[1])-399
				GMT2.GetInventory.Players[Char_Name].Crafting[CraftingSlot] = nil
				GMT2.GetInventory.Players[Char_Name].Crafting[CraftingSlot] = {Slot=CraftingSlot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}				
			elseif tonumber(Splitted_Data[1]) >= 700 and tonumber(Splitted_Data[1]) <= 799 then
				local QuestSlot = tonumber(Splitted_Data[1])-699
				GMT2.GetInventory.Players[Char_Name].Quest[QuestSlot] = nil				
				GMT2.GetInventory.Players[Char_Name].Quest[QuestSlot] = {Slot=QuestSlot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}								
			elseif tonumber(Splitted_Data[1]) >= 800 and tonumber(Splitted_Data[1]) <= 879 then
				local Bank_1Slot = tonumber(Splitted_Data[1])-799
				GMT2.GetInventory.Players[Char_Name].Bank_1[Bank_1Slot] = nil	
				GMT2.GetInventory.Players[Char_Name].Bank_1[Bank_1Slot] = {Slot=Bank_1Slot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}												
			elseif tonumber(Splitted_Data[1]) >= 880 and tonumber(Splitted_Data[1]) <= 959 then
				local Bank_2Slot = tonumber(Splitted_Data[1])-879
				GMT2.GetInventory.Players[Char_Name].Bank_2[Bank_2Slot] = nil	
				GMT2.GetInventory.Players[Char_Name].Bank_2[Bank_2Slot] = {Slot=Bank_2Slot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}																
			elseif tonumber(Splitted_Data[1]) >= 960 and tonumber(Splitted_Data[1]) <= 1039 then
				local Bank_3Slot = tonumber(Splitted_Data[1])-959
				GMT2.GetInventory.Players[Char_Name].Bank_3[Bank_3Slot] = nil					
				GMT2.GetInventory.Players[Char_Name].Bank_3[Bank_3Slot] = {Slot=Bank_3Slot,Stacks=tonumber(Splitted_Data[2]),ID=tonumber(Splitted_Data[3])}																				
			end		
		end
	end
	
	
WindowSetShowing(WindowName.."Bank_3Wnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 7)
WindowSetShowing(WindowName.."Bank_2Wnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 6)
WindowSetShowing(WindowName.."Bank_1Wnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 5)
WindowSetShowing(WindowName.."QuestWnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 4)	
WindowSetShowing(WindowName.."CraftingWnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 3)
WindowSetShowing(WindowName.."CurrencyWnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 2)
WindowSetShowing(WindowName.."ItemWnd",GMT2.GetInventory.Players[Char_Name].SelectedTab == 1)	

--Inventory	
local SlotCount = 1	
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."ItemWindow"..SlotCount) then
				DestroyWindow(WindowName.."ItemWindow"..SlotCount)			
			end
		
			if not DoesWindowExist(WindowName.."ItemWindow"..SlotCount) then
			CreateWindowFromTemplate(WindowName.."ItemWindow"..SlotCount, "ItemTemplate", WindowName.."ItemWnd")
			WindowClearAnchors( WindowName.."ItemWindow"..SlotCount )
			WindowAddAnchor( WindowName.."ItemWindow"..SlotCount , "topleft", WindowName.."ItemWnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
		LabelSetText(WindowName.."ItemWindow"..SlotCount.."IconSlotNum",towstring(39+SlotCount))
		LabelSetText(WindowName.."ItemWindow"..SlotCount.."IconSlotNumBG",towstring(39+SlotCount))				
		slotpos = slotpos+1
			SlotCount = SlotCount+1
		
			
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Inventory) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Inventory[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."ItemWindow"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."ItemWindow"..k.."Icon", texture, 64, 64)

		if proxyQuant > 1 then
		LabelSetText(WindowName.."ItemWindow"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."ItemWindow"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end
	
--Currency	
local SlotCount2 = 1	
for a=0,3 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."CurrencyWindow"..SlotCount2) then
				DestroyWindow(WindowName.."CurrencyWindow"..SlotCount2)			
			end		
			if not DoesWindowExist(WindowName.."CurrencyWindow"..SlotCount2) then
			CreateWindowFromTemplate(WindowName.."CurrencyWindow"..SlotCount2, "ItemTemplate", WindowName.."CurrencyWnd")
			WindowClearAnchors( WindowName.."CurrencyWindow"..SlotCount2 )
			WindowAddAnchor( WindowName.."CurrencyWindow"..SlotCount2 , "topleft", WindowName.."CurrencyWnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
		LabelSetText(WindowName.."CurrencyWindow"..SlotCount2.."IconSlotNum",towstring(499+SlotCount2))
		LabelSetText(WindowName.."CurrencyWindow"..SlotCount2.."IconSlotNumBG",towstring(499+SlotCount2))		
			
			slotpos = slotpos+1
			SlotCount2 = SlotCount2+1
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Currency) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Currency[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."CurrencyWindow"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."CurrencyWindow"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."CurrencyWindow"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."CurrencyWindow"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end
	
--Crafting	
local SlotCount3 = 1	
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."CraftingWindow"..SlotCount3) then
				DestroyWindow(WindowName.."CraftingWindow"..SlotCount3)			
			end		
			
			if not DoesWindowExist(WindowName.."CraftingWindow"..SlotCount3) then
			CreateWindowFromTemplate(WindowName.."CraftingWindow"..SlotCount3, "ItemTemplate", WindowName.."CraftingWnd")
			WindowClearAnchors( WindowName.."CraftingWindow"..SlotCount3 )
			WindowAddAnchor( WindowName.."CraftingWindow"..SlotCount3 , "topleft", WindowName.."CraftingWnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
		LabelSetText(WindowName.."CraftingWindow"..SlotCount3.."IconSlotNum",towstring(399+SlotCount3))
		LabelSetText(WindowName.."CraftingWindow"..SlotCount3.."IconSlotNumBG",towstring(399+SlotCount3))		
			slotpos = slotpos+1
			SlotCount3 = SlotCount3+1
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Crafting) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Crafting[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."CraftingWindow"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."CraftingWindow"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."CraftingWindow"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."CraftingWindow"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end

--Quest	
local SlotCount4 = 1	
--[[
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i			
			if not DoesWindowExist(WindowName.."QuestWindow"..SlotCount4) then
			CreateWindowFromTemplate(WindowName.."QuestWindow"..SlotCount4, "ItemTemplate", WindowName.."QuestWnd")
			WindowClearAnchors( WindowName.."QuestWindow"..SlotCount4 )
			WindowAddAnchor( WindowName.."QuestWindow"..SlotCount4 , "topleft", WindowName.."QuestWnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
			slotpos = slotpos+1
			SlotCount4 = SlotCount4+1
	end
end	
--]]

				local slotpos = 1
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Quest) do

			if not DoesWindowExist(WindowName.."QuestWindow"..k) then
			CreateWindowFromTemplate(WindowName.."QuestWindow"..k, "ItemTemplate", WindowName.."QuestWnd")
			WindowClearAnchors( WindowName.."QuestWindow"..k )
			WindowAddAnchor( WindowName.."QuestWindow"..k , "topleft", WindowName.."QuestWnd", "topleft", (42*slotpos)-30,42*(1)-10)
			end
	
	
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Quest[k].Data = ItemData
		local texture, x, y, disabledTexture =  GetIconData( 3455 )  --GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."QuestWindow"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."QuestWindow"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."QuestWindow"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."QuestWindow"..k.."IconNameBG",towstring(proxyQuant))

		LabelSetText(WindowName.."QuestWindow"..k.."IconSlotNum",towstring(699+k))
		LabelSetText(WindowName.."QuestWindow"..k.."IconSlotNumBG",towstring(699+k))	
		
		end	
			slotpos = slotpos+1
			--SlotCount4 = SlotCount4+1		
	end



--Bank_1	
local SlotCount5 = 1	
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."Bank_1Window"..SlotCount5) then
				DestroyWindow(WindowName.."Bank_1Window"..SlotCount5)			
			end		
			
			if not DoesWindowExist(WindowName.."Bank_1Window"..SlotCount5) then
			CreateWindowFromTemplate(WindowName.."Bank_1Window"..SlotCount5, "ItemTemplate", WindowName.."Bank_1Wnd")
			WindowClearAnchors( WindowName.."Bank_1Window"..SlotCount5 )
			WindowAddAnchor( WindowName.."Bank_1Window"..SlotCount5 , "topleft", WindowName.."Bank_1Wnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
		LabelSetText(WindowName.."Bank_1Window"..SlotCount5.."IconSlotNum",towstring(799+SlotCount5))
		LabelSetText(WindowName.."Bank_1Window"..SlotCount5.."IconSlotNumBG",towstring(799+SlotCount5))	
			
			slotpos = slotpos+1
			SlotCount5 = SlotCount5+1
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Bank_1) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Bank_1[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."Bank_1Window"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."Bank_1Window"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."Bank_1Window"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."Bank_1Window"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end
	
--Bank_2	
local SlotCount6 = 1	
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."Bank_2Window"..SlotCount6) then
				DestroyWindow(WindowName.."Bank_2Window"..SlotCount6)			
			end		
						
			if not DoesWindowExist(WindowName.."Bank_2Window"..SlotCount6) then
			CreateWindowFromTemplate(WindowName.."Bank_2Window"..SlotCount6, "ItemTemplate", WindowName.."Bank_2Wnd")
			WindowClearAnchors( WindowName.."Bank_2Window"..SlotCount6 )
			WindowAddAnchor( WindowName.."Bank_2Window"..SlotCount6 , "topleft", WindowName.."Bank_2Wnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
		LabelSetText(WindowName.."Bank_2Window"..SlotCount6.."IconSlotNum",towstring(879+SlotCount6))
		LabelSetText(WindowName.."Bank_2Window"..SlotCount6.."IconSlotNumBG",towstring(879+SlotCount6))	
			
			slotpos = slotpos+1
			SlotCount6 = SlotCount6+1
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Bank_2) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Bank_2[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."Bank_2Window"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."Bank_2Window"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."Bank_2Window"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."Bank_2Window"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end

--Bank_3	
local SlotCount7 = 1	
for a=0,9 do
	local slotpos = 1
	for i=(a*8)+1,8*(a+1) do
		local index = (a+1)*i	
			if DoesWindowExist(WindowName.."Bank_3Window"..SlotCount7) then
				DestroyWindow(WindowName.."Bank_3Window"..SlotCount7)			
			end		
							
			if not DoesWindowExist(WindowName.."Bank_3Window"..SlotCount7) then
			CreateWindowFromTemplate(WindowName.."Bank_3Window"..SlotCount7, "ItemTemplate", WindowName.."Bank_3Wnd")
			WindowClearAnchors( WindowName.."Bank_3Window"..SlotCount7 )
			WindowAddAnchor( WindowName.."Bank_3Window"..SlotCount7 , "topleft", WindowName.."Bank_3Wnd", "topleft", (42*slotpos)-30,42*(a+1)-10)
			end
			
		LabelSetText(WindowName.."Bank_3Window"..SlotCount7.."IconSlotNum",towstring(959+SlotCount6))
		LabelSetText(WindowName.."Bank_3Window"..SlotCount7.."IconSlotNumBG",towstring(959+SlotCount6))	
			
			slotpos = slotpos+1
			SlotCount7 = SlotCount7+1
	end
end	
	
	for k,v in pairs(GMT2.GetInventory.Players[Char_Name].Bank_3) do
		local ItemData = GetDatabaseItemData(tonumber(v.ID))
		local proxyQuant = v.Stacks
		
		GMT2.GetInventory.Players[Char_Name].Bank_3[k].Data = ItemData
		local texture, x, y, disabledTexture = GetIconData(tonumber(ItemData.iconNum)) 
		local color = DataUtils.GetItemRarityColor(ItemData)
		WindowSetTintColor(WindowName.."Bank_3Window"..k.."IconFrame",color.r, color.g, color.b)
		DynamicImageSetTexture(WindowName.."Bank_3Window"..k.."Icon", texture, 64, 64)
		if proxyQuant > 1 then
		LabelSetText(WindowName.."Bank_3Window"..k.."IconName",towstring(proxyQuant))
		LabelSetText(WindowName.."Bank_3Window"..k.."IconNameBG",towstring(proxyQuant))		
		end		
	end

ButtonSetPressedFlag( WindowName.."Bank_3Tab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 7 )	
ButtonSetPressedFlag( WindowName.."Bank_2Tab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 6 )	
ButtonSetPressedFlag( WindowName.."Bank_1Tab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 5 )	
ButtonSetPressedFlag( WindowName.."QuestTab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 4 )	
ButtonSetPressedFlag( WindowName.."CraftingTab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 3 )
ButtonSetPressedFlag( WindowName.."CurrencyTab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 2 )
ButtonSetPressedFlag( WindowName.."ItemsTab", GMT2.GetInventory.Players[Char_Name].SelectedTab == 1 )			

ButtonSetText(WindowName.."Bank_1Tab", L"1")
ButtonSetText(WindowName.."Bank_2Tab", L"2")
ButtonSetText(WindowName.."Bank_3Tab", L"3")	
end

function GMT2.GetInventory.ToggleTab()
	local ContextID = WindowGetId( SystemData.ActiveWindow.name )
	local WinParent = tostring(WindowGetParent(SystemData.MouseOverWindow.name))
	local WindowName = tostring(SystemData.MouseOverWindow.name)
	local ActiveWinParent = tostring(WindowGetParent(SystemData.ActiveWindow.name))
	local CharName = string.match( WinParent,"GetInventory_(.+)_")
	
	GMT2.GetInventory.Players[CharName].SelectedTab = tonumber(ContextID)
	
	WindowSetShowing(WinParent.."Bank_3Wnd",GMT2.GetInventory.Players[CharName].SelectedTab == 7)	
	WindowSetShowing(WinParent.."Bank_2Wnd",GMT2.GetInventory.Players[CharName].SelectedTab == 6)	
	WindowSetShowing(WinParent.."Bank_1Wnd",GMT2.GetInventory.Players[CharName].SelectedTab == 5)
	WindowSetShowing(WinParent.."QuestWnd",GMT2.GetInventory.Players[CharName].SelectedTab == 4)
	WindowSetShowing(WinParent.."CraftingWnd",GMT2.GetInventory.Players[CharName].SelectedTab == 3)
	WindowSetShowing(WinParent.."CurrencyWnd",GMT2.GetInventory.Players[CharName].SelectedTab == 2)
	WindowSetShowing(WinParent.."ItemWnd",GMT2.GetInventory.Players[CharName].SelectedTab == 1)	
	
	ButtonSetPressedFlag( WinParent.."Bank_3Tab", GMT2.GetInventory.Players[CharName].SelectedTab == 7 )
	ButtonSetPressedFlag( WinParent.."Bank_2Tab", GMT2.GetInventory.Players[CharName].SelectedTab == 6 )
	ButtonSetPressedFlag( WinParent.."Bank_1Tab", GMT2.GetInventory.Players[CharName].SelectedTab == 5 )
	ButtonSetPressedFlag( WinParent.."QuestTab", GMT2.GetInventory.Players[CharName].SelectedTab == 4 )
	ButtonSetPressedFlag( WinParent.."CraftingTab", GMT2.GetInventory.Players[CharName].SelectedTab == 3 )
	ButtonSetPressedFlag( WinParent.."CurrencyTab", GMT2.GetInventory.Players[CharName].SelectedTab == 2 )
	ButtonSetPressedFlag( WinParent.."ItemsTab", GMT2.GetInventory.Players[CharName].SelectedTab == 1 )
	
	
end

function GMT2.GetInventory.Mouse()
	local WinParent = WindowGetParent(SystemData.MouseOverWindow.name)
	local WindowName = tostring(SystemData.MouseOverWindow.name)

	local ItemTest
	
	if string.match( WindowName,"ItemWindow(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_ItemWnd")
	local WinId = tonumber(string.match( WindowName,"ItemWindow(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Inventory[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Inventory[WinId].Data
		end
	elseif string.match( WindowName,"CurrencyWindow(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_CurrencyWnd")
	local WinId = tonumber(string.match( WindowName,"CurrencyWindow(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Currency[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Currency[WinId].Data
		end	
	elseif string.match( WindowName,"CraftingWindow(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_CraftingWnd")
	local WinId = tonumber(string.match( WindowName,"CraftingWindow(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Crafting[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Crafting[WinId].Data
		end	
	elseif string.match( WindowName,"QuestWindow(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_QuestWnd")
	local WinId = tonumber(string.match( WindowName,"QuestWindow(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Quest[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Quest[WinId].Data
		end		
	elseif string.match( WindowName,"Bank_1Window(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_Bank_1Wnd")
	local WinId = tonumber(string.match( WindowName,"Bank_1Window(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Bank_1[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Bank_1[WinId].Data
		end	
	elseif string.match( WindowName,"Bank_2Window(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_Bank_2Wnd")
	local WinId = tonumber(string.match( WindowName,"Bank_2Window(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Bank_2[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Bank_2[WinId].Data
		end	
	elseif string.match( WindowName,"Bank_3Window(%d+)Icon") then
	local CharName = string.match( WindowGetParent(WindowGetParent(SystemData.MouseOverWindow.name)),"GetInventory_(.+)_Bank_3Wnd")
	local WinId = tonumber(string.match( WindowName,"Bank_3Window(%d+)Icon"))
		if GMT2.GetInventory.Players[CharName].Bank_3[WinId] ~= nil then
			ItemTest = GMT2.GetInventory.Players[CharName].Bank_3[WinId].Data
		end							
	end
 
if ItemTest ~= nil then
local TooltipAnchor = { Point = "topleft",  RelativeTo = ButtonName, RelativePoint = "bottomleft",   XOffset = 0, YOffset = -10 }
Tooltips.CreateItemTooltip(ItemTest , SystemData.ActiveWindow.name, TooltipAnchor, true, nil, nil, true )
end
end


function GMT2.GetInventory.Update()
	local WinParent = tostring(WindowGetParent(SystemData.MouseOverWindow.name))
	local CharName = string.match( WinParent,"GetInventory_(.+)_")
	SendChatText(L"]player inventory "..towstring(CharName), ChatSettings.Channels[0].serverCmd)	
end