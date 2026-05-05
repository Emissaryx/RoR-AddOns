if not LibWBTogglerManager then LibWBTogglerManager = {} end
local LibWBTogglerManager = LibWBTogglerManager
local GUI, dimCheck
local WGD, ssub = WindowGetDimensions, string.sub
local modDimensions = {}
LibConfig = LibStub("LibConfig")

local function trim(s)
	return ssub(s, 17)
end

function LibWBTogglerManager.Initialize()
	if LibSlash then LibSlash.RegisterSlashCmd("wbtm", LibWBTogglerManager.ToggleManager) end
	RegisterEventHandler(SystemData.Events.LOADING_END, "LibWBTogglerManager.CheckMods")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "LibWBTogglerManager.CheckMods")
	RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "LibWBTogglerManager.CheckMods")
	WindowSetShowing("WBTogglerManagerButton", true)
	WindowAddAnchor("WBTogglerManagerButton", "right", "WarBoardOptionsTabsBottomBoardTab", "left", 5, 0)
end

function LibWBTogglerManager.ToggleManager()
	if not GUI then
		GUI = LibConfig("WarBoard Togglers", LibWBToggler.modsSettings, true, LibWBTogglerManager.ResizeMods)

		for item, _ in pairs(LibWBToggler.modsSettings) do
			if item ~= "version" then
				GUI:AddTab(trim(item))
				GUI("checkbox", "Show Label", {item, "label"})
				GUI("checkbox", "Show Icon", {item, "icon"})
			end
		end
	end
	if GUI.window:Showing() then GUI:Hide() else GUI:Show() end
end

function LibWBTogglerManager.CheckMods()
	for k, v in pairs(LibWBToggler.modsSettings) do
		if k ~= "version" then 
			LibWBToggler.ListChanged(k)
		end
	end
	GUI = nil
	if not dimCheck then LibWBTogglerManager.GetDimensions() end
	LibWBTogglerManager.ResizeMods()
end

function LibWBTogglerManager.GetDimensions()
	for _, modName in ipairs(LibWBToggler.mods) do
		local xTotal, _ = WGD(modName); local xLabel, _ = WGD(modName.."Label"); local xIcon = WGD(modName.."Icon")
		modDimensions[modName] = { total = xTotal, label = xLabel, icon = xIcon }
	end
	dimCheck = true
end

function LibWBTogglerManager.ResizeMods()
	for k1,v1 in pairs(LibWBToggler.modsSettings) do
		if k1 ~= "version" then
			local x = modDimensions[v1.name].total
			for k2, v2 in pairs(v1) do
				if k2 == "icon" then
					WindowSetShowing(k1.."Icon", v2)
					if not v2 then 
						x = x - modDimensions[k1].icon
						WindowClearAnchors(k1.."Label")	WindowAddAnchor(k1.."Label", "topleft", k1, "topleft", 3, 0)
					else
						WindowClearAnchors(k1.."Label")	WindowAddAnchor(k1.."Label", "right", k1.."Icon", "left", 2, 0)
					end
				elseif k2 == "label" then
					WindowSetShowing(k1.."Label", v2)
					if not v2 then x = x - modDimensions[k1].label  end
				end
			end
			WindowSetDimensions(k1, x, 30)
		end
		WarBoard.SortMods()
	end
end
