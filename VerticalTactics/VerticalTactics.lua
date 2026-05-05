----------------------------------------------------------------
-- VerticalTactics.lua
----------------------------------------------------------------

VerticalTactics = VerticalTactics or {}
VerticalTactics.reverse = VerticalTactics.reverse or false

-- Internal state
VerticalTactics._hooked = VerticalTactics._hooked or false
VerticalTactics._dirty  = true

-- Localize globals
local ipairs              = ipairs
local DoesWindowExist     = DoesWindowExist
local WindowGetDimensions = WindowGetDimensions
local WindowSetDimensions = WindowSetDimensions
local WindowClearAnchors  = WindowClearAnchors
local WindowAddAnchor     = WindowAddAnchor
local WindowGetScale      = WindowGetScale
local WindowSetScale      = WindowSetScale
local WindowSetShowing    = WindowSetShowing
local EA_ChatWindow_Print = EA_ChatWindow and EA_ChatWindow.Print

local function Print(msg)
	if EA_ChatWindow_Print then
		EA_ChatWindow_Print(msg)
	end
end

function VerticalTactics.Initialize()
	-- Ensure dependency module is initialized if present
	local modules = ModulesGetData()
	for _, v in ipairs(modules) do
		if v.name == "EA_TacticsWindow_WifNamez" then
			if v.isEnabled and not v.isLoaded then
				ModuleInitialize("EA_TacticsWindow_WifNamez")
			end
			break
		end
	end

	-- Hook once
	if not VerticalTactics._hooked and TacticsEditor then
		VerticalTactics._hooked = true

		local oldCreateBar = TacticsEditor.CreateBar
		if oldCreateBar then
			TacticsEditor.CreateBar = function(...)
				oldCreateBar(...)
				VerticalTactics._dirty = true
				VerticalTactics.AnchorTacticButtons()
			end
		end

		local oldUpdateTactics = TacticsEditor.UpdateTactics
		if oldUpdateTactics then
			TacticsEditor.UpdateTactics = function(...)
				oldUpdateTactics(...)
				VerticalTactics._dirty = true
				VerticalTactics.AnchorTacticButtons()
			end
		end

		local oldShutdown = TacticsEditor.Shutdown
		if oldShutdown then
			TacticsEditor.Shutdown = function(...)
				VerticalTactics.Shutdown()
				oldShutdown(...)
			end
		end
	end

	-- Slash command
	if LibSlash and LibSlash.RegisterSlashCmd then
		LibSlash.RegisterSlashCmd("verticaltactics", function(args)
			args = args or ""
			local cmd = args:match("^reverse%s+(%w+)$")
			if cmd == "true" then
				VerticalTactics.reverse = true
				VerticalTactics._dirty = true
				VerticalTactics.AnchorTacticButtons()
				return
			elseif cmd == "false" then
				VerticalTactics.reverse = false
				VerticalTactics._dirty = true
				VerticalTactics.AnchorTacticButtons()
				return
			end

			Print(L"[VerticalTactics]: Valid options are:\n reverse [true|false]: enable/disable reverse mode")
		end)
	end

	-- Initial layout attempt (safe)
	VerticalTactics._dirty = true
	VerticalTactics.AnchorTacticButtons()
end

function VerticalTactics.Shutdown()
	-- Restore editor to wider-than-tall if it was left vertical
	if DoesWindowExist("EA_TacticsEditor") then
		local x, y = WindowGetDimensions("EA_TacticsEditor")
		if y > x then
			WindowSetDimensions("EA_TacticsEditor", y, x)
		end
	end
end

function VerticalTactics.AnchorTacticButtons()
	if not DoesWindowExist("EA_TacticsEditor") then
		return
	end

	-- Only re-anchor when needed
	if not VerticalTactics._dirty then
		return
	end
	VerticalTactics._dirty = false

	-- Force editor into vertical layout (taller than wide)
	local dimX, dimY = WindowGetDimensions("EA_TacticsEditor")
	if dimX > dimY then
		WindowSetDimensions("EA_TacticsEditor", dimY, dimX)
	end

	-- Anchor the set menu to top or bottom depending on reverse mode
	WindowClearAnchors("EA_TacticsEditorContentsSetMenu")
	if VerticalTactics.reverse then
		WindowAddAnchor("EA_TacticsEditorContentsSetMenu", "bottomleft", "EA_TacticsEditor", "bottomleft", 0, 0)
	else
		WindowAddAnchor("EA_TacticsEditorContentsSetMenu", "topleft", "EA_TacticsEditor", "topleft", 0, 0)
	end

	local scale = WindowGetScale("EA_TacticsEditor")

	local anchorToWindow = "EA_TacticsEditor"
	local offsetX = 1
	local offsetY = 47
	local relativePoint = "topleft"
	local point = "topleft"

	if VerticalTactics.reverse then
		offsetY = -47
		relativePoint = "bottomleft"
		point = "bottomleft"
	end

	for buttonId = 1, GameData.MAX_TACTICS_SLOTS do
		local windowName = "TacticButton" .. buttonId
		if not DoesWindowExist(windowName) then
			break
		end

		if buttonId > 1 then
			local prev = "TacticButton" .. (buttonId - 1)
			anchorToWindow = prev
			offsetX = 0

			if VerticalTactics.reverse then
				offsetY = -2
				point = "topleft"
				relativePoint = "bottomleft"
			else
				offsetY = 2
				point = "bottomleft"
				relativePoint = "topleft"
			end
		end

		WindowClearAnchors(windowName)
		WindowSetScale(windowName, scale)
		WindowAddAnchor(windowName, point, anchorToWindow, relativePoint, offsetX, offsetY)
	end

	-- Hide spacers (we are stacking vertically)
	for slotType = GameData.TacticType.FIRST, GameData.TacticType.NUM_TYPES do
		local spacer = "Spacer" .. slotType
		if DoesWindowExist(spacer) then
			WindowSetShowing(spacer, false)
		end
	end
end
