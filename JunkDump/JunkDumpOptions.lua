JunkDumpOptions = {}

JunkDumpOptions.RadioButton = ""
JunkDumpOptions.inventoryItemData = 0
JunkDumpOptions.attachedInventorySlotID = 0

JunkDumpOptions.dataDisplayed = {}
JunkDumpOptions.itemsDataHolder = {}
JunkDumpOptions.MAX_VISIBLE_ROWS = 5

local uiStrings = {}

local RowItem = 
{
	itemName,
}

local function print(txt)
	ChatWindow.Print(towstring(txt))
end

function JunkDumpOptions.Initialize()
	uiStrings = JunkDumpLocalization.getUIStrings(SystemData.Settings.Language.active)
	JunkDumpOptions.CreateOptionsWindow()
	d("JunkDump Options Loaded...")
end

function JunkDumpOptions.CreateOptionsWindow()
	CreateWindow("JunkDumpOptionsWin", false)
	WindowSetMovable("JunkDumpOptionsWin", true)
	CreateWindow("JunkDumpOptionsProfessionsWin", false)
	WindowSetMovable("JunkDumpOptionsProfessionsWin", true)
	
	LabelSetText("JunkDumpOptionsWinTitleBarText", uiStrings[1])
	LabelSetText("JunkDumpOptionsProfessionsWinTitleBarText", uiStrings[2])
	
	LabelSetText("JunkDumpOptionsWinBagModeLabel", uiStrings[3])
	LabelSetText("JunkDumpOptionsWinBagModeOnLabel", uiStrings[4])
	LabelSetText("JunkDumpOptionsWinBagModeOffLabel", uiStrings[5])
	
	LabelSetText("JunkDumpOptionsWinGoldReportLabel", uiStrings[6])
	LabelSetText("JunkDumpOptionsWinGoldReportOnLabel", uiStrings[7])
	LabelSetText("JunkDumpOptionsWinGoldReportOffLabel", uiStrings[8])
	
	LabelSetText("JunkDumpOptionsWinItemReportLabel", uiStrings[9])
	LabelSetText("JunkDumpOptionsWinItemReportOnLabel", uiStrings[10])
	LabelSetText("JunkDumpOptionsWinItemReportOffLabel", uiStrings[11])
	
	LabelSetText("JunkDumpOptionsProfessionsWinSellTalismanLabel", uiStrings[12])
	LabelSetText("JunkDumpOptionsProfessionsWinSellTalismanOnLabel", uiStrings[13])
	LabelSetText("JunkDumpOptionsProfessionsWinSellTalismanOffLabel", uiStrings[14])
	LabelSetText("JunkDumpOptionsProfessionsWinSellTalismanMaxLabel", uiStrings[15])
	
	LabelSetText("JunkDumpOptionsProfessionsWinSellApothLabel", uiStrings[16])
	LabelSetText("JunkDumpOptionsProfessionsWinSellApothOnLabel", uiStrings[17])
	LabelSetText("JunkDumpOptionsProfessionsWinSellApothOffLabel", uiStrings[18])
	LabelSetText("JunkDumpOptionsProfessionsWinSellApothMaxLabel", uiStrings[19])
	
	LabelSetText("JunkDumpOptionsProfessionsWinSellCultivationLabel", uiStrings[20])
	LabelSetText("JunkDumpOptionsProfessionsWinSellCultivationOnLabel", uiStrings[21])
	LabelSetText("JunkDumpOptionsProfessionsWinSellCultivationOffLabel", uiStrings[22])
	LabelSetText("JunkDumpOptionsProfessionsWinSellCultivationMaxLabel", uiStrings[23])
	
	LabelSetText("JunkDumpOptionsProfessionsWinSellSalvagingLabel", uiStrings[24])
	LabelSetText("JunkDumpOptionsProfessionsWinSellSalvagingOnLabel", uiStrings[25])
	LabelSetText("JunkDumpOptionsProfessionsWinSellSalvagingOffLabel", uiStrings[26])
	LabelSetText("JunkDumpOptionsProfessionsWinSellSalvagingMaxLabel", uiStrings[27])
	
	LabelSetText("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityLabel", uiStrings[28])
	LabelSetText("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityOnLabel", uiStrings[29])
	LabelSetText("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityOffLabel", uiStrings[30])
	
	LabelSetText("JunkDumpOptionsWinBagModeBagLabel", uiStrings[31])
	LabelSetText("JunkDumpOptionsWinBagModeBagOneLabel", L"1")
	LabelSetText("JunkDumpOptionsWinBagModeBagTwoLabel", L"2")
	LabelSetText("JunkDumpOptionsWinBagModeBagThreeLabel", L"3")
	LabelSetText("JunkDumpOptionsWinBagModeBagFourLabel", L"4")
	LabelSetText("JunkDumpOptionsWinBagModeBagFiveLabel", L"5")
	LabelSetText("JunkDumpOptionsWinBagModeBagSixLabel", L"6")
	
	LabelSetText("JunkDumpOptionsWinRarityLabel", uiStrings[32])
	LabelSetText("JunkDumpOptionsWinRarityOneLabel", uiStrings[33])
	LabelSetText("JunkDumpOptionsWinRarityTwoLabel", uiStrings[34])
	LabelSetText("JunkDumpOptionsWinRarityThreeLabel", uiStrings[35])
	LabelSetText("JunkDumpOptionsWinRarityFourLabel", uiStrings[36])
	LabelSetText("JunkDumpOptionsWinRarityFiveLabel", uiStrings[37])
	LabelSetText("JunkDumpOptionsWinRaritySixLabel", uiStrings[38])
	
	ButtonSetText("JunkDumpOptionsWinTestModeRunButton", uiStrings[39])
	ButtonSetText("JunkDumpOptionsWinTestModeClearButton", uiStrings[40])
	ButtonSetText("JunkDumpOptionsWinAboutButton", uiStrings[41])
	ButtonSetText("JunkDumpOptionsWinProfessionsButton", uiStrings[42])
	
	local maxBags = JunkDump.getMaxBags()	
	JunkDumpOptions.DynamicBagOptions(maxBags)
	JunkDumpOptions.InitSettings()
end

function JunkDumpOptions.DynamicBagOptions(maxBags)
	if(maxBags == 1) then
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox2", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagTwoLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox3", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagThreeLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox4", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFourLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox5", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFiveLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox6", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagSixLabel", false)
	end
	if(maxBags == 2) then
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox3", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagThreeLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox4", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFourLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox5", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFiveLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox6", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagSixLabel", false)
	end
	if(maxBags == 3) then
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox4", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFourLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox5", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFiveLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox6", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagSixLabel", false)
	end
	if(maxBags == 4) then
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox5", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagFiveLabel", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox6", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagSixLabel", false)
	end
	if(maxBags == 5) then
		WindowSetShowing("JunkDumpOptionsWinBagModeBagCheckbox6", false)
		WindowSetShowing("JunkDumpOptionsWinBagModeBagSixLabel", false)
	end
end

function JunkDumpOptions.InitSettings()
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagMode == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeCheckboxOffButton",false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button", false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button", false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button", false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button", false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button", false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button", false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagMode == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeCheckboxOnButton",false)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button", true)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button", true)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button", true)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button", true)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button", true)
		ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button", true)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowGoldReport == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsWinGoldReportCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinGoldReportCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowGoldReport == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsWinGoldReportCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinGoldReportCheckboxOnButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowItemsReport == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsWinItemReportCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinItemReportCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowItemsReport == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsWinItemReportCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinItemReportCheckboxOnButton",false)
	end
	
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellApoth == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellApothCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellApothCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellApoth == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellApothCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellApothCheckboxOnButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellTalisman == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellTalisman == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOnButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellCultivation == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellCultivation == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOnButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellSalvaging == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellSalvaging == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOnButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].IgnoreProfessionRarity == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOnButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOffButton",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].IgnoreProfessionRarity == 0 then
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOffButton",true)
		ButtonSetPressedFlag("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOnButton",false)
	end
	TextEditBoxSetText("JunkDumpOptionsProfessionsWinSellApothMax", L"" .. JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ApothMax .. L"")
	TextEditBoxSetText("JunkDumpOptionsProfessionsWinSellTalismanMax", L"" .. JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].TalismanMax .. L"")
	TextEditBoxSetText("JunkDumpOptionsProfessionsWinSellCultivationMax", L"" .. JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].CultivationMax .. L"")
	TextEditBoxSetText("JunkDumpOptionsProfessionsWinSellSalvagingMax", L"" .. JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SalvagingMax .. L"")

	
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 2 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 3 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 4 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 5 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag == 6 then
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button",true)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 1 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 2 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 3 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 4 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 5 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",true)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",false)
	end
	if JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold == 6 then
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox1Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox2Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox3Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox4Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox5Button",false)
		ButtonSetPressedFlag("JunkDumpOptionsWinRarityCheckbox6Button",true)
	end
end

function JunkDumpOptions.UpdateBagModeOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81381 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagMode = 1
				ButtonSetPressedFlag("JunkDumpOptionsWinBagModeCheckboxOffButton",false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button", false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button", false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button", false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button", false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button", false)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button", false)
			end
			if JunkDumpOptions.RadioButton == 81382 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagMode = 0
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox1Button", true)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox2Button", true)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox3Button", true)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox4Button", true)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox5Button", true)
				ButtonSetDisabledFlag("JunkDumpOptionsWinBagModeBagCheckbox6Button", true)
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsWinBagModeCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsWinBagModeCheckboxOff")    
end

function JunkDumpOptions.UpdateGoldReportOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81383 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowGoldReport = 1
			end
			if JunkDumpOptions.RadioButton == 81384 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowGoldReport = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsWinGoldReportCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsWinGoldReportCheckboxOff")    
end

function JunkDumpOptions.UpdateItemReportOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81385 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowItemsReport = 1
			end
			if JunkDumpOptions.RadioButton == 81386 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ShowItemsReport = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsWinItemReportCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsWinItemReportCheckboxOff")    
end

function JunkDumpOptions.UpdateBagModeBag()
	if ButtonGetDisabledFlag(SystemData.MouseOverWindow.name.."Button") then return end
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81389 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 1
			end
			if JunkDumpOptions.RadioButton == 81390 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 2
			end
			if JunkDumpOptions.RadioButton == 81391 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 3
			end
			if JunkDumpOptions.RadioButton == 81392 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 4
			end
			if JunkDumpOptions.RadioButton == 81393 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 5
			end
			if JunkDumpOptions.RadioButton == 81394 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].BagModeBag = 6
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox1")
	CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox2")
	CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox3")
	CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox4")
	CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox5")
	CheckAndSetButton("JunkDumpOptionsWinBagModeBagCheckbox6")
end

function JunkDumpOptions.UpdateRarity()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81395 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 1
			end
			if JunkDumpOptions.RadioButton == 81396 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 2
			end
			if JunkDumpOptions.RadioButton == 81397 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 3
			end
			if JunkDumpOptions.RadioButton == 81398 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 4
			end
			if JunkDumpOptions.RadioButton == 81399 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 5
			end
			if JunkDumpOptions.RadioButton == 81400 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].RarityThreshold = 6
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox1")
	CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox2")
	CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox3")
	CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox4")
	CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox5")
	CheckAndSetButton("JunkDumpOptionsWinRarityCheckbox6")
end

function JunkDumpOptions.UpdateSellApothOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81401 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellApoth = 1
			end
			if JunkDumpOptions.RadioButton == 81402 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellApoth = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsProfessionsWinSellApothCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsProfessionsWinSellApothCheckboxOff")    
end

function JunkDumpOptions.UpdateSellTalismanOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81403 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellTalisman = 1
			end
			if JunkDumpOptions.RadioButton == 81404 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellTalisman = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsProfessionsWinSellTalismanCheckboxOff")    
end

function JunkDumpOptions.UpdateSellCultivationOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81405 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellCultivation = 1
			end
			if JunkDumpOptions.RadioButton == 81406 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellCultivation = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsProfessionsWinSellCultivationCheckboxOff")    
end

function JunkDumpOptions.UpdateSellSalvagingOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81407 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellSalvaging = 1
			end
			if JunkDumpOptions.RadioButton == 81408 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SellSalvaging = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsProfessionsWinSellSalvagingCheckboxOff")    
end

function JunkDumpOptions.UpdateIgnoreProfessionRarityOnOff()
    local function CheckAndSetButton(ButtonName)
        if (JunkDumpOptions.RadioButton == WindowGetId( ButtonName ))
        then
            ButtonSetPressedFlag(ButtonName.."Button", true)
			if JunkDumpOptions.RadioButton == 81387 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].IgnoreProfessionRarity = 1
			end
			if JunkDumpOptions.RadioButton == 81388 then
				JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].IgnoreProfessionRarity = 0
			end
        else
            ButtonSetPressedFlag(ButtonName.."Button", false)
        end
    end
    JunkDumpOptions.RadioButton = WindowGetId(SystemData.ActiveWindow.name)
    CheckAndSetButton("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOn")
	CheckAndSetButton("JunkDumpOptionsProfessionsWinIgnoreProfessionRarityCheckboxOff")    
end

function JunkDumpOptions.UpdateApothMax()
	JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].ApothMax = tonumber(TextEditBoxGetText("JunkDumpOptionsProfessionsWinSellApothMax"))
end

function JunkDumpOptions.UpdateTalismanMax()
	JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].TalismanMax = tonumber(TextEditBoxGetText("JunkDumpOptionsProfessionsWinSellTalismanMax"))
end

function JunkDumpOptions.UpdateCultivationMax()
	JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].CultivationMax = tonumber(TextEditBoxGetText("JunkDumpOptionsProfessionsWinSellCultivationMax"))
end

function JunkDumpOptions.UpdateSalvagingMax()
	JunkDumpSettings[""..JunkDump.ServerNameString..""][""..JunkDump.CharacterNameString..""].SalvagingMax = tonumber(TextEditBoxGetText("JunkDumpOptionsProfessionsWinSellSalvagingMax"))
end

function JunkDumpOptions.Show()
	JunkDumpOptions.InitSettings()
	WindowSetShowing("JunkDumpOptionsWin", true)
end

function JunkDumpOptions.ShowAbout()
     Tooltips.CreateTextOnlyTooltip (SystemData.ActiveWindow.name)
     Tooltips.SetTooltipText (1, 1,  L"About JunkDump           by Daegalus")
     Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
     Tooltips.SetTooltipText (2, 1,  L"Many thanks to everyone at #WARDevUI  ")
     Tooltips.SetTooltipText (3, 1,  L"@chat.freenode.net. Especially Aiiane,")
     Tooltips.SetTooltipText (4, 1,  L"hopefully I haven't tried her patience")
     Tooltips.SetTooltipText (5, 1,  L"with my stupid questions and mistakes.")
     Tooltips.SetTooltipText (6, 1,  L" ")
	 Tooltips.SetTooltipColorDef (6, 1, Tooltips.COLOR_HEADING)
     Tooltips.SetTooltipText (7, 1,  L"Please post any bugs or problems on   ")
     Tooltips.SetTooltipText (8, 1,  L"the projects Curseforge/Curse page or ")
     Tooltips.SetTooltipText (9, 1,  L"message on AIM @ Daegalus if urgent.  ")
     Tooltips.Finalize();
     Tooltips.AnchorTooltip( { Point = "topleft",  RelativeTo = SystemData.ActiveWindow.name, RelativePoint = "bottomleft",   XOffset = 0, YOffset = -10 } )
end

function JunkDumpOptions.ShowProfessions()
	JunkDumpOptions.InitSettings()
	WindowSetShowing("JunkDumpOptionsProfessionsWin", true)
end

function JunkDumpOptions.DoneProfessions()
	WindowSetShowing("JunkDumpOptionsProfessionsWin", false)
end
function JunkDumpOptions.Done()
	WindowSetShowing("JunkDumpOptionsWin", false)
end

function JunkDumpOptions.DestroyOptionsWindow()
	DestroyWindow("JunkDumpOptionsWin")
end
