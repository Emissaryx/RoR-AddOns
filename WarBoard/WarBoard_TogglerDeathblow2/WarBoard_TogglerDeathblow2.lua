if not WarBoard_TogglerDeathblow2 then WarBoard_TogglerDeathblow2 = {} end
local WarBoard_TogglerDeathblow2 = WarBoard_TogglerDeathblow2
local modName = "WarBoard_TogglerDeathblow2"
local modLabel = "DB2"

function WarBoard_TogglerDeathblow2.Initialize()

	if LibWBToggler.CreateToggler(modName, modLabel, "db2iconv4", 0, 0) then
		WindowSetDimensions(modName, 80, 30)
		WindowSetDimensions(modName.."Label", 30, 30)
		LibWBToggler.RegisterEvent(modName, "OnLButtonUp", "WarBoard_TogglerDeathblow2.Deathblow2")
		LibWBToggler.RegisterEvent(modName, "OnMButtonDown", "WarBoard_TogglerDeathblow2.Soloq")
		LibWBToggler.RegisterEvent(modName, "OnMouseOver", "WarBoard_TogglerDeathblow2.ShowStatus")
	end
end

function WarBoard_TogglerDeathblow2.Deathblow2()
	if not Deathblow then
		EA_ChatWindow.Print(L"Deathblow2 addon is not loaded.")
		return;		
	end
	DB_Show();
end

function WarBoard_TogglerDeathblow2.Soloq()
	if Soloq then
		Soloq.toggleOverviewWindow();
	end
end

function WarBoard_TogglerDeathblow2.ShowStatus()
	LibWBToggler.DefaultTooltip(modName, "Deathblow2");
end
