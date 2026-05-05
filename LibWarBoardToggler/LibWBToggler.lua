if not LibWBToggler then LibWBToggler = {} end
local LibWBToggler, version = LibWBToggler, "1.5"
if not LibWBToggler.modsSettings or LibWBToggler.modsSettings.version ~= version then LibWBToggler.modsSettings = {version = version} end
local WindowRegisterCoreEventHandler = WindowRegisterCoreEventHandler
local CreateWindowFromTemplate, DynamicImageSetTexture, GetIconData = CreateWindowFromTemplate, DynamicImageSetTexture, GetIconData
local tinsert, towstring, smatch, gsub, sfind, Tooltips = table.insert, towstring, string.match, string.gsub, string.find, Tooltips
local ipairs = ipairs
local WBTT = "WBTogglerTemplate"
LibWBToggler.events, LibWBToggler.funcs, LibWBToggler.mods = {}, {}, {}

local function SetIcon(dynamicImageTitle, icon)
	local texture, x, y = GetIconData(icon)
	DynamicImageSetTexture(dynamicImageTitle, texture, x, y)
end

function LibWBToggler.CreateToggler(modName, modLabel, modIcon, xIcon, yIcon, texSlice, texScale)
	CreateWindowFromTemplate(modName, WBTT, "Root")
	tinsert(WarBoard.LoadedMods, modName)
	tinsert(LibWBToggler.mods, modName)
	LabelSetText(modName.."Label", towstring(modLabel))
	if type(modIcon) == "number" then SetIcon(modName.."Icon", modIcon)
	elseif type(modIcon) == "string" then 
		DynamicImageSetTexture(modName.."Icon", modIcon, xIcon, yIcon)
		if texSlice then DynamicImageSetTextureSlice(modName.."Icon", texSlice) end
		if texScale then DynamicImageSetTextureScale(modName.."Icon", texScale) end
	end
	LibWBToggler.events[modName], LibWBToggler.funcs[modName] = {}, {}
	LibWBToggler.ListChanged(modName)
	return true
end

function LibWBToggler.RegisterEvent(modName, coreEvent, func)
	WindowRegisterCoreEventHandler(modName, coreEvent, func)
	if sfind(coreEvent, "LButton") then coreEvent = "Left Click:"
	elseif sfind(coreEvent, "RButton") then coreEvent = "Right Click:"
	elseif sfind(coreEvent, "MButton") then coreEvent = "Middle Click:"
	elseif sfind(coreEvent, "MouseOver") or sfind(coreEvent, "OnUpdate") then return end
	func = smatch(func, "[^.]+$")
	func = gsub(func, "%u", " %1")
	tinsert(LibWBToggler.events[modName], coreEvent)
	tinsert(LibWBToggler.funcs[modName], func)
	return true
end

function LibWBToggler.DefaultTooltip(modName, modTitle)
	local event, func, row = LibWBToggler.events[modName], LibWBToggler.funcs[modName], 2
-- To Do: Coloring, Versatile Tooltips
	Tooltips.CreateTextOnlyTooltip(modName, nil)
	Tooltips.AnchorTooltip(WarBoard.GetModToolTipAnchor(modName))
	local tempName = modTitle or gsub(smatch(modName, "[^_]+$"), "%u", " %1")
	Tooltips.SetTooltipText(1, 1, towstring(tempName))
	for _,v in ipairs(LibWBToggler.events[modName]) do
		Tooltips.SetTooltipText(row, 1, towstring(v))
		row = row +1
	end
	row = 2
	for _,v in ipairs(LibWBToggler.funcs[modName]) do
		Tooltips.SetTooltipText(row, 3, towstring(v))
		row = row +1
	end
	Tooltips.Finalize()
end

function LibWBToggler.ListChanged(modName)
	if not LibWBToggler.modsSettings[modName] then
		LibWBToggler.modsSettings[modName] = {name = modName, label = true, icon = true}
	else
		local modExists
		for _,v in ipairs(LibWBToggler.mods) do
			if v == modName then modExists = true end
		end
		if not modExists then LibWBToggler.modsSettings[modName] = nil end
	end
end
