	if not GuardLine then GuardLine = {} end

local scroll_pixels_current = 0
local scroll_pixels_max = 62      -- width of the texture
local scroll_pixels_rate = 62     -- pixels per second
local Update_Throttle = 0.001
local Throttle_Counter = Update_Throttle

	local Version = 1.7
	local DriftTimer = 0
	local ProtectAngle = 0
	local UIScale = InterfaceCore.GetScale()
    local ResolutionScale = InterfaceCore.GetResolutionScale()	
	local GlobalScale = SystemData.Settings.Interface.globalUiScale	
	local ScreenWidthX,ScreenHeightY = GetScreenResolution()	
	local ObjecOffset = 1
	local G_Range_Out = "Close"
	local G_Range_In = "Close"
	local IsTeathered = 0.1
	local IsTeatheredOffGuard = 0.1	
	local NumberOfGuards = 0		
		
		
	local GUARDED_APPLY_ID = 1			--when another player add guard to you
	local GUARDED_REMOVE_ID = 2			--when another players guard removes from you
	local GUARDING_APPLY_ID = 3			--when you add guard to another player
	local GUARDING_REMOVE_ID = 4			--when your guard removes from another player
		
	local GuardTexture = {[true]="XGuardLine",[false]="GuardLineLine"}
	local GuardIcons = {["Close"]="GuardIcon",["Mid"]="BreakIcon",["Far"]="BreakIcon",["Distant"]="DistantIcon",["Dead"]="DeadIcon"}	
	
	local OutTexturePack = "Modern_"
	local InTexturePack = "Modern_"
	
-- Make utility functions local for performance
	local pairs = pairs
	local ipairs = ipairs
	local tonumber = tonumber
	local towstring = towstring
	local tostring = tostring
	local max = math.max
	local min = math.min
	local WindowGetScale = WindowGetScale
	local WindowGetShowing = WindowGetShowing
	local WindowSetAlpha = WindowSetAlpha
	local WindowSetShowing = WindowSetShowing
	local WindowSetTintColor = WindowSetTintColor
	local WindowSetScale = WindowSetScale

	local CreateWindowFromTemplate,WindowSetDimensions,WindowClearAnchors,WindowAddAnchor,
      WindowRegisterCoreEventHandler,WindowSetLayer,DestroyWindow,RegisterEventHandler,
      DynamicImageSetTextureDimensions,DynamicImageSetTexture,DynamicImageSetRotation,	  
      StatusBarSetMaximumValue,StatusBarSetCurrentValue,StatusBarSetForegroundTint,
      LabelSetText,LabelSetTextColor =
     _G["CreateWindowFromTemplate"],_G["WindowSetDimensions"],_G["WindowClearAnchors"],_G["WindowAddAnchor"],
     _G["WindowRegisterCoreEventHandler"],_G["WindowSetLayer"],_G["DestroyWindow"],_G["RegisterEventHandler"],
     _G["DynamicImageSetTextureDimensions"],_G["DynamicImageSetTexture"],_G["DynamicImageSetRotation"],	 
     _G["StatusBarSetMaximumValue"],_G["StatusBarSetCurrentValue"],_G["StatusBarSetForegroundTint"],
     _G["LabelSetText"],_G["LabelSetTextColor"] 
	
	
	
function GuardLine.init()
	CreateWindow("GuardLineSelfWindow", true)
	WindowSetAlpha("GuardLineSelfWindow",0)
	CreateWindow("GuardLineTargetWindow", false)
	CreateWindow("GuardLineOffGuardSelfWindow", false)
	CreateWindow("GuardLineOffGuardTargetWindow", false)


	CreateWindow("GuardLineScaleWindow", true)
	CreateWindow("GuardLineLine", true)
	CreateWindow("GuardLineOffGuardLine", true)

	if GuardLine.Settings == nil or (GuardLine.Settings.version < Version) then GuardLine.ResetSettings() end

	OutTexturePack = GuardLine.Settings.OutTexturePack
	InTexturePack = GuardLine.Settings.InTexturePack
	
	LayoutEditor.RegisterWindow( "GuardLineSelfWindow", L"GuardLine Window", L"GuardLine Window", false, false, false)
	LayoutEditor.RegisterEditCallback(GuardLine.OnLayoutEditorFinished)

	CircleImageSetTexture( "GuardLineOffGuardTargetWindowIcon", "GuardIcon", 32, 32 )
	CircleImageSetTexture( "GuardLineOffGuardSelfWindowIcon", "GuardIcon", 32, 32 )	

	UIScale = (InterfaceCore.GetScale())
    ResolutionScale = (InterfaceCore.GetResolutionScale())
	GlobalScale = (SystemData.Settings.Interface.globalUiScale)
	ScreenWidthX,ScreenHeightY = GetScreenResolution()	
	ObjecOffset = 1
	GuardLine.TargetID = 0
	GuardLine.TargetName = L""
	GuardLine.TargetInfo = {}
	GuardLine.OffGuardID = 0
	GuardLine.OffGuardName = L""
	GuardLine.ClosestOffGuardID = 0
	GuardLine.ClosestOffGuardName = L""
	
	WindowSetShowing("GuardLineSelfWindow",true)
	WindowSetAlpha("GuardLineSelfWindow",0)
	WindowSetShowing("GuardLineTargetWindow",false)		
	WindowSetShowing("GuardLineOffGuardTargetWindow",false) 
	WindowSetShowing("GuardLineOffGuardSelfWindow",false) 
	
	if LibGuard then 
		LibGuard.Register_Callback(GuardLine.Libguard_Toggle)		
	end
	if LibSlash then
		LibSlash.RegisterSlashCmd("teather", function(input) GuardLine.Command(input) end)		
		LibSlash.RegisterSlashCmd("guardline", function(input) GuardLine.Command(input) end)
		LibSlash.RegisterSlashCmd("fakeguard", function(input) GuardLine.FakeGuard(input) end)		
	end
	
	AnimatedImageStartAnimation ("GuardLineSelfWindowGlow", 0, true, true, 0)	
	AnimatedImageStartAnimation ("GuardLineTargetWindowGlow", 0, true, true, 0)		
	
	WindowSetScale("GuardLineSelfWindow",UIScale*GuardLine.Settings.Scale)
	WindowSetScale("GuardLineTargetWindow",UIScale*GuardLine.Settings.Scale)	
	WindowSetScale("GuardLineOffGuardSelfWindow",UIScale*GuardLine.Settings.Scale)
	WindowSetScale("GuardLineOffGuardTargetWindow",UIScale*GuardLine.Settings.Scale)
	WindowSetScale("GuardLineLine",UIScale*GuardLine.Settings.Scale)
	WindowSetScale("GuardLineOffGuardLine",UIScale*GuardLine.Settings.Scale)

  WindowClearAnchors ("GuardLineScaleWindow")
  WindowAddAnchor ("GuardLineScaleWindow", "topleft", "Root", "topleft", SystemData.screenResolution.x / 2, SystemData.screenResolution.y / 2)

	DynamicImageSetTexture ("GuardLineLineLine", OutTexturePack.."GuardLineLine", 0, 0)
	DynamicImageSetTexture ("GuardLineOffGuardLineLine", InTexturePack.."GuardLineLine2", 0, 0)
end

function GuardLine.OnLayoutEditorFinished( editorCode )
	if( editorCode == LayoutEditor.EDITING_END ) then
		--WindowSetShowing("GuardLineSelfWindow",false)
		WindowSetAlpha("GuardLineSelfWindow",0)
		WindowSetShowing("GuardLineTargetWindow",false)		
		WindowSetShowing("GuardLineOffGuardTargetWindow",false) 
		WindowSetShowing("GuardLineOffGuardSelfWindow",false) 
	end
end

function GuardLine.OnLayoutEditorStart()
		WindowSetShowing("LayoutEditorWindowEditGuardLineSelfWindowControlsTopLeftResize",false)
		WindowSetShowing("LayoutEditorWindowEditGuardLineSelfWindowControlsTopRightResize",false)
		WindowSetShowing("LayoutEditorWindowEditGuardLineSelfWindowControlsBottomLeftResize",false)
		WindowSetShowing("LayoutEditorWindowEditGuardLineSelfWindowControlsBottomRightResize",false)
		return
end


--Attach/deatach and Show/Hide the GuardLine windows
function GuardLine.GetIDs()
if LibGuard.FakeGuarding == true and LibGuard.UsePet == true then

	if (GameData.Player.Pet.healthPercent > 0) then

	GuardLine.TargetID = GameData.Player.Pet.objNum
	--GuardLine.TargetName = GameData.Player.Pet.name
	GuardLine.TargetName = wstring.gsub(GuardLine.FixString(GameData.Player.Pet.name),GuardLine.FixString(GameData.Player.name)..L"'s","")
	IsTeathered = 0.1
	WindowSetShowing("GuardLineTargetWindow",true) 
	--WindowSetShowing("GuardLineSelfWindow",true) 
	WindowSetAlpha("GuardLineSelfWindow",GuardLine.Settings.Alpha)
	WindowSetAlpha("GuardLineTargetWindow",GuardLine.Settings.Alpha)	
	else
	GuardLine.TargetID = TargetInfo:UnitEntityId("selffriendlytarget")
	GuardLine.TargetName = L"FakeGuardOut"
	IsTeathered = 0.1
	WindowSetShowing("GuardLineTargetWindow",true) 
	--WindowSetShowing("GuardLineSelfWindow",true) 
	WindowSetAlpha("GuardLineSelfWindow",GuardLine.Settings.Alpha)
	WindowSetAlpha("GuardLineTargetWindow",GuardLine.Settings.Alpha)		
	end
return
end

	local PlayerName = GuardLine.FixString(GameData.Player.name)
	GuardLine.TargetID = TargetInfo:UnitEntityId("selffriendlytarget")
	GuardLine.TargetName = GuardLine.FixString(TargetInfo:UnitName("selffriendlytarget"))

	if GuardLine.TargetName ~= L"" and not (GuardLine.TargetName == PlayerName) then 
		IsTeathered = 0.1
		WindowSetShowing("GuardLineTargetWindow",true) 
		--WindowSetShowing("GuardLineSelfWindow",true) 
		WindowSetAlpha("GuardLineTargetWindow",GuardLine.Settings.Alpha)
		WindowSetAlpha("GuardLineSelfWindow",GuardLine.Settings.Alpha)

	else
		IsTeathered = 0.1
		WindowSetShowing("GuardLineTargetWindow",false) 
		--WindowSetShowing("GuardLineSelfWindow",false)
		WindowSetAlpha("GuardLineSelfWindow",GuardLine.Settings.Alpha)
		GuardLine.TargetID = 0	
	end	
end


function GuardLine.update(timeElapsed)
--If in Layout editor, Hide them pesky resize controlls
	if LayoutEditor.isActive then
		if DoesWindowExist("LayoutEditorWindowEditGuardLineSelfWindowControls") then
			GuardLine.OnLayoutEditorStart()
		end	
	end


	if GuardLine.Settings.Scroll == true then
  -- Scroll the texture. Needs to be done before rotation/etc.
		scroll_pixels_current = scroll_pixels_current + scroll_pixels_rate * timeElapsed
		scroll_pixels_current = math.fmod (scroll_pixels_current, scroll_pixels_max)
	end	
	
-- HARD GUARD CONTEXT EXIT
if (GuardLine.TargetName == nil or GuardLine.TargetName == L"")
and not LibGuard.FakeGuarding
and not IsWarBandActive()
and not PartyUtils.IsPartyActive()
and not GameData.Player.isInScenario
and not GameData.Player.isInSiege
then
    WindowSetShowing("GuardLineTargetWindow", false)
    WindowSetShowing("GuardLineOffGuardTargetWindow", false)
    WindowSetShowing("GuardLineOffGuardSelfWindow", false)

    WindowSetAlpha("GuardLineLine", 0)
    WindowSetAlpha("GuardLineOffGuardLine", 0)
    WindowSetAlpha("GuardLineSelfWindow", 0)

    GuardLine.TargetID = 0
    GuardLine.TargetInfo = {}

    return
end

--[[
--Update Throttle:
if Throttle_Counter > 0 then
	Throttle_Counter = Throttle_Counter-timeElapsed
	return 
	else
Throttle_Counter = Update_Throttle
end
--]]


	local IsTargetGuarded = LibGuard.GuarderData.Name == GuardLine.TargetName
	local distance = -1
	local Range = -1

	OutTexturePack = GuardLine.Settings.OutTexturePack
	
	if GuardLine.TargetName ~= nil and GuardLine.TargetName ~= L"" then
	local IsXguard = Check_XGuard()
		--Did i mentioned i hate math? because im just so terrible at it...
		--Only check for distance if in a party,warband or scenario
		if IsWarBandActive() or PartyUtils.IsPartyActive() or GameData.Player.isInScenario or GameData.Player.isInSiege then
			distance = LibGuard.GuarderData.distance
			Range  = LibGuard.GuarderData.Range
			GuardLine.TargetID = LibGuard.GuarderData.ID
			GuardLine.TargetInfo = LibGuard.GuarderData.Info
		end

			WindowClearAnchors( "GuardLineTargetWindowCircle" )
			WindowAddAnchor( "GuardLineTargetWindowCircle" , "center", "GuardLineTargetWindow", "center", 0,GuardLine.Settings.AnchorOffset)	
			WindowClearAnchors( "GuardLineTargetWindowIcon" )
			WindowAddAnchor( "GuardLineTargetWindowIcon" , "center", "GuardLineTargetWindow", "center", 0,GuardLine.Settings.AnchorOffset)	
					
			
			local IsDistant = true
			local IsDead = false
			if LibGuard.GuarderData.Info ~= nil then
				if LibGuard.GuarderData.Info ~= 0 then
					IsDistant = LibGuard.GuarderData.Info.isDistant
				end
				if LibGuard.GuarderData.Info.healthPercent <= 0 then
					IsDead = true
				end
				
			end
			local Color = GuardLine.Settings.Colors.Default
			
			
			if IsDead == false then
				if IsDistant == true then 
					Color = GuardLine.Settings.Colors.Distant
					G_Range_Out = "Distant"
				else
					if distance < 0 then
					Color = GuardLine.Settings.Colors.Default
					G_Range_Out = "Close"
					elseif distance <= 30 and distance >= 0 then
						Color = GuardLine.Settings.Colors.Close
						G_Range_Out = "Close"
					elseif distance > 30 and distance <= 50 then
						Color = GuardLine.Settings.Colors.Mid
						G_Range_Out = "Mid"					
					elseif distance > 50 then
						Color = GuardLine.Settings.Colors.Far
						G_Range_Out = "Far"
					else
						Color = GuardLine.Settings.Colors.Distant
						G_Range_Out = "Distant"
					end
				end
			else
					Color = GuardLine.Settings.Colors.Dead
					G_Range_Out = "Dead"
			end
		

			if distance > 0 and distance < 170 and not IsDistant and GuardLine.Settings.Range == true then
--Range Circle
			local RangeSize = 1 + (Range/150)
			local RangeFade = (GuardLine.Settings.Alpha-0.2) -(Range /250)
			WindowSetScale("GuardLineSelfWindowRange",WindowGetScale("GuardLineSelfWindowCircle")*RangeSize)
			WindowSetTintColor("GuardLineSelfWindowRange",Color.r,Color.g,Color.b)
			WindowSetAlpha("GuardLineSelfWindowRange",RangeFade)
			WindowSetShowing("GuardLineSelfWindowRange",true)
			else
				WindowSetShowing("GuardLineSelfWindowRange",false)
			end

--======================================================
-- Zomegas rotate/stretch Code
--======================================================

  WindowSetShowing ("GuardLineTargetWindow", true)
  -- Calculate current UI scaling by trying to move the test window to the
  -- middle of the screen and seeing where it actually ends up. Scaling should
  -- be identical for the X and Y axis.

  local anchored_x = WindowGetScreenPosition ("GuardLineScaleWindow")
  local scale_xy = ((SystemData.screenResolution.x / 2) / anchored_x)

	local angle = 0
	local length = 0
  -- Early-out if there is no friendly target.



				if  GuardLine.TargetID ~= nil then
					MoveWindowToWorldObject("GuardLineTargetWindow", GuardLine.TargetID, ObjecOffset)--0.9962 for player 0.9975
					ForceUpdateWorldObjectWindow(GuardLine.TargetID,"GuardLineTargetWindow")
				end

if (WindowGetShowing ("GuardLineTargetWindow") == true) then
  -- Early-out if the anchor point for the target object is off-screen.
  --MoveWindowToWorldObject ("GuardLineTargetWindow", GuardLine.TargetID, ObjecOffset)

  -- We need to scroll towards the end point which in this case means negating
  -- the scroll value. If we were scrolling towards the start point then the
  -- positive value would be used.
 if GuardLine.Settings.Scroll == true then
  DynamicImageSetTexture ("GuardLineLineLine", OutTexturePack..tostring(GuardTexture[IsXguard]), -scroll_pixels_current, 0)
end
  -- The line will be drawn from the middle of the screen to the target point.
  -- The middle of the line is centered in the middle of the screen and the line
  -- will then be rotated around that point. To begin with, we need to calculate
  -- the middle of the screen, the line's anchor point, the rotation angle, and
  -- the distance between the start end end. Don't actually start moving the
  -- line window yet.
  local end_x, end_y = WindowGetScreenPosition ("GuardLineTargetWindow")
  local start_x,start_y = WindowGetScreenPosition ("GuardLineSelfWindow")

	start_x = start_x +((35/scale_xy)*GuardLine.Settings.Scale)
	start_y = start_y +((35/scale_xy)*GuardLine.Settings.Scale)

	end_x = end_x +((35/scale_xy)*GuardLine.Settings.Scale)
	end_y = end_y +(((35+GuardLine.Settings.AnchorOffset)/scale_xy)*GuardLine.Settings.Scale)
  local diff_x = end_x - start_x
  local diff_y = end_y - start_y 
  length = (math.sqrt ((diff_x * diff_x) + (diff_y * diff_y)))/GuardLine.Settings.Scale

  local mid_x = start_x + (diff_x / 2)
  local mid_y = start_y + (diff_y / 2)

  local dir_x = diff_x / length
  local dir_y = diff_y / length

  angle = math.atan2 (dir_y, dir_x) / (math.pi / 180)

  -- Rotate the image first around an un-anchored mid-point. Clearing the anchor
  -- of the parent seemed to fix a lot of weird rotation issues and allowed it
  -- to rotate in place. The length has to be scaled by scale_xy otherwise it
  -- will end up too show as WindowSetDimentions will modify the input based on
  -- the current UI scale. 14 is the height of the image/window.
  WindowClearAnchors ("GuardLineLine")
  WindowSetDimensions ("GuardLineLineLine", (length-44) * scale_xy, 14)
  DynamicImageSetRotation ("GuardLineLineLine", angle)
  WindowSetAlpha ("GuardLineLine", GuardLine.Settings.Alpha)

  -- Now the rotation is done, move the mid-point of the line window. Needs to
  -- be scaled as WindowAddAnchor also modifies the inputs based on UI scale
  -- which we do not want.
  -- Fix the mid point after this calculations to adjust for the rotation. This
  -- is needed as DynamicImageSetRotation doesn't correctly account for the
  -- height of the window. Height is 14, so we have to adjust by half (7).
  mid_x = mid_x - (dir_y * (7/scale_xy))
  mid_y = mid_y + (dir_x * (7/scale_xy))

  -- Now the rotation is done, move the mid-point of the line window. Needs to
  -- be scaled as WindowAddAnchor also modifies the inputs based on UI scale
  -- which we do not want.
  WindowAddAnchor ("GuardLineLine", "topleft", "Root", "topleft", mid_x * scale_xy, mid_y * scale_xy)
else
WindowSetAlpha ("GuardLineLine", 0.0)
end


  if (GuardLine.TargetID == 0)
  then
    WindowSetAlpha ("GuardLineLine", 0.0)
--    return
  end

--============================================
	
-- ==========================================================================
		
				WindowSetTintColor("GuardLineSelfWindow",Color.r,Color.g,Color.b)
				WindowSetTintColor("GuardLineTargetWindow",Color.r,Color.g,Color.b)		
				WindowSetTintColor("GuardLineLine",Color.r,Color.g,Color.b)


				if IsTeathered > 0 then 
					IsTeathered = IsTeathered-timeElapsed
				else
					if (length+22) <= (scroll_pixels_max) then
		
						--WindowSetAlpha("TeatherLine1Line",0)
						DynamicImageSetTexture("GuardLineSelfWindowCircle",OutTexturePack.."CircleBG", 0,0)
						DynamicImageSetTexture("GuardLineTargetWindowCircle",OutTexturePack.."CircleBG", 0,0)
					else
						if WindowGetShowing("GuardLineTargetWindow") == true and IsDistant == false then
						DynamicImageSetTexture("GuardLineSelfWindowCircle",OutTexturePack.."GuardLineArrow", 0,0)
						DynamicImageSetTexture("GuardLineTargetWindowCircle",OutTexturePack.."GuardLineArrow", 0,0)
						else
						DynamicImageSetTexture("GuardLineSelfWindowCircle",OutTexturePack.."CircleBG", 0,0)
						DynamicImageSetTexture("GuardLineTargetWindowCircle",OutTexturePack.."CircleBG", 0,0)
						end
	
						--WindowSetAlpha("GuardLineLine1Line",ShowLines)
					end
				end	

		local S_x,S_y = WindowGetScreenPosition("GuardLineTargetWindow")	
		if  (S_x+ S_y) == 0 or WindowGetAlpha("GuardLineSelfWindow") == 0 or (WindowGetShowing("GuardLineSelfWindow")) == false or (IsDistant == true) then
			WindowSetShowing("GuardLineTargetWindow",false) 
			WindowSetAlpha ("GuardLineLine", 0.0)
			end


		if LibGuard.FakeGuarding == true and (GameData.Player.Pet.healthPercent > 0) and LibGuard.UsePet == true then
			CircleImageSetTexture( "GuardLineTargetWindowIcon", "PetIcon", 32, 32 )
			CircleImageSetTexture( "GuardLineSelfWindowIcon", "PetIcon", 32, 32 )
		else
			CircleImageSetTexture( "GuardLineTargetWindowIcon", GuardIcons[G_Range_Out], 32, 32 )
			CircleImageSetTexture( "GuardLineSelfWindowIcon", GuardIcons[G_Range_Out], 32, 32 )
		end
	

	local ShowGlow = ((tostring(LibGuard.GuarderData.Name) == tostring(GuardLine.OffGuardName)) and (IsXguard)) or (LibGuard.FakeGuarding == true and LibGuard.FakeGuarded == true and (IsXguard))
		WindowSetTintColor("GuardLineSelfWindowGlow",Color.r,Color.g,Color.b)	
		WindowSetTintColor("GuardLineTargetWindowGlow",Color.r,Color.g,Color.b)	
		WindowSetShowing("GuardLineSelfWindowGlow",ShowGlow and IsTargetGuarded)	
		WindowSetShowing ("GuardLineTargetWindowGlow", ShowGlow and IsTargetGuarded)	

				DynamicImageSetRotation("GuardLineTargetWindowCircle",angle+90)
				DynamicImageSetRotation("GuardLineSelfWindowCircle",angle-90)

	else
		WindowSetAlpha ("GuardLineLine", 0.0)
	end

	GuardLine.update2(timeElapsed)

end

--This is for OffGuard Tethering
function GuardLine.update2(timeElapsed)

	local IsDistant = true
	GuardLine.OffGuardInfo = LibGuard.GetIdFromName(tostring(GuardLine.OffGuardName),3)

	if GuardLine.OffGuardInfo ~= nil and GuardLine.OffGuardInfo ~= 0 then
		IsDistant = GuardLine.OffGuardInfo.isDistant
	end
	
	InTexturePack = GuardLine.Settings.InTexturePack
	
	if GuardLine.OffGuardName ~= nil and GuardLine.OffGuardName ~= L"" then
	local IsTargetGuarded = LibGuard.GuarderData.Name == GuardLine.TargetName
	local distance = 0 
	local Color = GuardLine.Settings.Colors.Default

		if LibGuard.registeredGuards[tostring(GuardLine.OffGuardName)] ~= nil then
			distance = LibGuard.registeredGuards[tostring(GuardLine.OffGuardName)].distance
			
			if IsDistant == true then
				Color = GuardLine.Settings.Colors.Distant
				G_Range_In = "Distant"
			else
				if distance < 0 then
					Color = GuardLine.Settings.Colors.Default
					G_Range_In = "Close"
				elseif distance <= 30 and distance >= 0 then
					Color = GuardLine.Settings.Colors.Close
					G_Range_In = "Close"
				elseif distance > 30 and distance <= 50 then
					Color = GuardLine.Settings.Colors.Mid
					G_Range_In = "Mid"
				elseif distance > 50 then
					Color = GuardLine.Settings.Colors.Far
					G_Range_In = "Far"
				else
					Color = GuardLine.Settings.Colors.Distant
					G_Range_In = "Distant"
				end
			end	
		end

		
			WindowClearAnchors( "GuardLineOffGuardTargetWindowCircle" )
			WindowAddAnchor( "GuardLineOffGuardTargetWindowCircle" , "center", "GuardLineOffGuardTargetWindow", "center", 0,(GuardLine.Settings.AnchorOffset))	
			WindowClearAnchors( "GuardLineOffGuardTargetWindowIcon" )
			WindowAddAnchor( "GuardLineOffGuardTargetWindowIcon" , "center", "GuardLineOffGuardTargetWindow", "center", 0,(GuardLine.Settings.AnchorOffset))	

--======================================================
-- Zomegas rotate/stretch Code
--======================================================				




  WindowSetShowing ("GuardLineOffGuardTargetWindow", true)


  local anchored_x = WindowGetScreenPosition ("GuardLineScaleWindow")
  local scale_xy = ((SystemData.screenResolution.x / 2) / anchored_x)

	local angle = 0
	local length = 0


				local ShowLines = GuardLine.Settings.Alpha --0
				--local ShowXlines = (tostring(LibGuard.GuarderData.Name) == tostring(GuardLine.OffGuardName)) or (LibGuard.GuarderData.ID == LibGuard.registeredGuards["FakeGuardIn"].ID)
				--if WindowGetShowing("GuardLineOffGuardTargetWindow") == true and (Check_XGuard() == false) then ShowLines = GuardLine.Settings.Alpha end
							
				if WindowGetShowing("GuardLineOffGuardTargetWindow") == true and (tostring(LibGuard.GuarderData.Name) ~= tostring(GuardLine.ClosestOffGuardName)) then
					 if (LibGuard.FakeGuarded == true and LibGuard.FakeGuarding == true and Check_XGuard() == true) then
						ShowLines = 0
					else
						ShowLines = GuardLine.Settings.Alpha
					end					
				else
					ShowLines = 0
				end
				if GuardLine.OffGuardID ~= nil then
					MoveWindowToWorldObject("GuardLineOffGuardTargetWindow", GuardLine.OffGuardID, ObjecOffset)--0.9962 for player 0.9975
					ForceUpdateWorldObjectWindow(GuardLine.OffGuardID,"GuardLineOffGuardTargetWindow")
				end

if (WindowGetShowing ("GuardLineOffGuardTargetWindow") == true) then
 if GuardLine.Settings.Scroll == true then
  DynamicImageSetTexture ("GuardLineOffGuardLineLine", InTexturePack.."GuardLineLine2", scroll_pixels_current, 0)
end

  local end_x, end_y = WindowGetScreenPosition ("GuardLineOffGuardTargetWindow")
  local start_x,start_y = WindowGetScreenPosition ("GuardLineOffGuardSelfWindow")

	start_x = start_x +((35/scale_xy)*GuardLine.Settings.Scale)
	start_y = start_y +((35/scale_xy)*GuardLine.Settings.Scale)

	end_x = end_x +((35/scale_xy)*GuardLine.Settings.Scale)
	end_y = end_y +(((35+GuardLine.Settings.AnchorOffset)/scale_xy)*GuardLine.Settings.Scale)
  local diff_x = end_x - start_x
  local diff_y = end_y - start_y 
  length = (math.sqrt ((diff_x * diff_x) + (diff_y * diff_y))/GuardLine.Settings.Scale)

  local mid_x = start_x + (diff_x / 2)
  local mid_y = start_y + (diff_y / 2)

  local dir_x = diff_x / length
  local dir_y = diff_y / length

  angle = math.atan2 (dir_y, dir_x) / (math.pi / 180)

  WindowClearAnchors ("GuardLineOffGuardLine")
  WindowSetDimensions ("GuardLineOffGuardLineLine", (length-31) * scale_xy, 10)
  DynamicImageSetRotation ("GuardLineOffGuardLineLine", angle)
  WindowSetAlpha ("GuardLineOffGuardLine", GuardLine.Settings.Alpha)

  mid_x = mid_x - (dir_y * (5/scale_xy))
  mid_y = mid_y + (dir_x * (5/scale_xy))

  WindowAddAnchor ("GuardLineOffGuardLine", "topleft", "Root", "topleft", mid_x * scale_xy, mid_y * scale_xy)
else
	WindowSetAlpha ("GuardLineOffGuardLine", 0.0)
end


  if (GuardLine.TargetID == 0)
  then
    --WindowSetAlpha ("GuardLineOffGuardLine", 0.0)
--    return
  end

--============================================
	
-- ==========================================================================

				
				WindowSetTintColor("GuardLineOffGuardSelfWindow",Color.r,Color.g,Color.b)
				WindowSetTintColor("GuardLineOffGuardTargetWindow",Color.r,Color.g,Color.b)		
				WindowSetTintColor("GuardLineOffGuardLine",Color.r,Color.g,Color.b)

				if IsTeatheredOffGuard > 0 then 
					IsTeatheredOffGuard = IsTeatheredOffGuard-timeElapsed
				else
					if (length+26) <= (scroll_pixels_max) then	
						DynamicImageSetTexture("GuardLineOffGuardSelfWindowCircle",InTexturePack.."CircleIn", 0,0)
						DynamicImageSetTexture("GuardLineOffGuardTargetWindowCircle",InTexturePack.."CircleIn", 0,0)
						WindowSetAlpha("GuardLineOffGuardLine",0)
					else
						if WindowGetShowing("GuardLineOffGuardTargetWindow") == true and IsDistant == false then
								if Check_XGuard() == true then
									DynamicImageSetTexture("GuardLineOffGuardSelfWindowCircle",InTexturePack.."CircleIn", 0,0)
									DynamicImageSetTexture("GuardLineOffGuardTargetWindowCircle",InTexturePack.."CircleIn", 0,0)
								else
									DynamicImageSetTexture("GuardLineOffGuardSelfWindowCircle",InTexturePack.."GuardLineArrowIn", 0,0)						
									DynamicImageSetTexture("GuardLineOffGuardTargetWindowCircle",InTexturePack.."GuardLineArrowIn", 0,0)						
								end
						else
							DynamicImageSetTexture("GuardLineOffGuardSelfWindowCircle",InTexturePack.."CircleIn", 0,0)
							DynamicImageSetTexture("GuardLineOffGuardTargetWindowCircle",InTexturePack.."CircleIn", 0,0)
						end
						WindowSetAlpha("GuardLineOffGuardLine",ShowLines)
					end
				end	
			
				DynamicImageSetRotation("GuardLineOffGuardSelfWindowCircle",angle-90)
				DynamicImageSetRotation("GuardLineOffGuardTargetWindowCircle",angle+90)

	end
	if (LibGuard.registeredGuards == nil or (NumberOfGuards == 0) or (tostring(LibGuard.GuarderData.Name) == tostring(GuardLine.OffGuardName))) and (IsTargetGuarded) then
		WindowSetShowing("GuardLineOffGuardSelfWindow",false)
	else
		WindowSetShowing("GuardLineOffGuardSelfWindow",true)
		GuardLine.OffTarget()
	end	

	local S_x,S_y = WindowGetScreenPosition("GuardLineOffGuardTargetWindow")	
	if  ((S_x+ S_y) == 0 or (WindowGetShowing("GuardLineOffGuardSelfWindow")) == false) or (IsDistant == true) then
		if LibGuard.FakeGuarded == false then
			WindowSetShowing("GuardLineOffGuardTargetWindow",false) 
			WindowSetAlpha("GuardLineOffGuardLine",0) 
		end
	end

	CircleImageSetTexture( "GuardLineOffGuardTargetWindowIcon", GuardIcons[G_Range_In], 32, 32 )
	CircleImageSetTexture( "GuardLineOffGuardSelfWindowIcon", GuardIcons[G_Range_In], 32, 32 )
	WindowSetAlpha( "GuardLineOffGuardTargetWindow", GuardLine.Settings.Alpha )
	WindowSetAlpha( "GuardLineOffGuardSelfWindow",GuardLine.Settings.Alpha )

end

function GuardLine.OffTarget()
NumberOfGuards = 0
local Range = 999999
GuardLine.OffGuardName = L""


	if LibGuard.FakeGuarded == true and LibGuard.registeredGuards["FakeGuardIn"] ~= nil then
			GuardLine.OffGuardID = LibGuard.registeredGuards["FakeGuardIn"].ID
			GuardLine.OffGuardName = LibGuard.registeredGuards["FakeGuardIn"].Name	
			NumberOfGuards = 1
			GuardLine.ClosestOffGuardName = LibGuard.registeredGuards["FakeGuardIn"].Name
			GuardLine.ClosestOffGuardID = LibGuard.registeredGuards["FakeGuardIn"].ID

	return
	end

			
	for key, value in pairs( LibGuard.registeredGuards ) do	
	NumberOfGuards = NumberOfGuards+1
	
		if LibGuard.registeredGuards[key].distance ~= nil and LibGuard.registeredGuards[key].distance < Range then
			Range = LibGuard.registeredGuards[key].distance		
			GuardLine.OffGuardID = LibGuard.registeredGuards[key].ID
			GuardLine.OffGuardName = towstring(key)	
			
			if Check_XGuard() == true and (towstring(LibGuard.GuarderData.Name) ~= towstring(key)) then
				GuardLine.ClosestOffGuardName = towstring(key)
				GuardLine.ClosestOffGuardID = LibGuard.registeredGuards[key].ID
			else
				GuardLine.ClosestOffGuardName = towstring(key)
				GuardLine.ClosestOffGuardID = LibGuard.registeredGuards[key].ID
			end

			
		end		
	end			
	
	if (NumberOfGuards == 0) then	
			IsTeatheredOffGuard = 0.1
			WindowSetShowing("GuardLineOffGuardTargetWindow",false) 
			WindowSetShowing("GuardLineOffGuardSelfWindow",false)
			GuardLine.OffGuardID = 0	
			GuardLine.OffGuardName = L""
			GuardLine.ClosestOffGuardName = L""
			GuardLine.ClosestOffGuardID = 0
	end	
return		
end

function GuardLine.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end

function GuardLine.Libguard_Toggle(state,GuardedName,GuardedID)
--d(L"State:"..towstring(state)..L" Name:"..towstring(GuardedName)..L" ID:"..towstring(GuardedID))
		if state == GUARDED_APPLY_ID then
		GuardLine.OffGuardID = GuardedID
		GuardLine.OffGuardName = towstring(GuardedName)		
		IsTeatheredOffGuard = 0.1
		WindowSetShowing("GuardLineOffGuardTargetWindow",true) 
		WindowSetShowing("GuardLineOffGuardSelfWindow",true) 
		GuardLine.OffTarget()
		elseif state == GUARDED_REMOVE_ID then
		GuardLine.OffTarget()		
		elseif state == GUARDING_REMOVE_ID then
			GuardLine.TargetName = L""
			IsTeathered = 0.1
			WindowSetShowing("GuardLineTargetWindow",false) 
			--WindowSetShowing("GuardLineSelfWindow",false)
			WindowSetAlpha("GuardLineSelfWindow",0)
			GuardLine.TargetID = 0			
		elseif state == GUARDING_APPLY_ID then
			GuardLine.TargetName = towstring(GuardedName)
			IsTeathered = 0.1
			WindowSetShowing("GuardLineTargetWindow",true) 
			--WindowSetShowing("GuardLineSelfWindow",true) 
			WindowSetAlpha("GuardLineSelfWindow",GuardLine.Settings.Alpha)
			GuardLine.GetIDs()			
		end			
end

function GuardLine.Command(input)
	local input1 = nil
	local input2 = nil
	
	input1 = string.sub(input,0,string.find(input," "))
	if string.find(input," ") ~= nil then
		input1 = string.sub(input,0,string.find(input," ")-1)
		input2 = string.sub(input,string.find(input," ")+1,-1)
	end

	if (input1 == "offset") then
		if (input2 == "") or (input2 == nil) then
			EA_ChatWindow.Print(L"Input offset for Target Guard icon, (Current offset: "..towstring(GuardLine.Settings.AnchorOffset)..L")")
			return		
		else
			GuardLine.Settings.AnchorOffset = tonumber(input2)
		end
	elseif (input1 == "scale") then
		if (input2 == "") or (input2 == nil) then
			EA_ChatWindow.Print(L"Input scale for GuardLine frames, !! NEEDS A '/reloadui' AFTER CHANGE !! (Current scale: "..towstring(GuardLine.Settings.Scale)..L")")
			return		
		else
			GuardLine.Settings.Scale = tonumber(input2)
		end
	elseif (input1 == "range") then
			GuardLine.Settings.Range = not GuardLine.Settings.Range
	elseif (input1 == "alpha") then
		if (input2 == "") or (input2 == nil) then
			EA_ChatWindow.Print(L"Input Alpha for the Lines and icons,(Current Alpha: "..towstring(GuardLine.Settings.Alpha)..L")")
			return		
		else
			GuardLine.Settings.Alpha = tonumber(input2)
		end			
	elseif (input1 == "frame") then
		if(input2 == "modern") then
			GuardLine.Settings.OutTexturePack = "Modern_"
			GuardLine.Settings.InTexturePack = "Modern_"
		elseif(input2 == "classic") then
			GuardLine.Settings.OutTexturePack = "Classic_"
			GuardLine.Settings.InTexturePack = "Classic_"
		elseif(input2 == "small") then
			GuardLine.Settings.OutTexturePack = "Small_"
			GuardLine.Settings.InTexturePack = "Small_"
		elseif(input2 == "dots") then
			GuardLine.Settings.OutTexturePack = "Dots_"			
			GuardLine.Settings.InTexturePack = "Dots_"
		elseif(input2 == "chain") then
			GuardLine.Settings.OutTexturePack = "Chain_"			
			GuardLine.Settings.InTexturePack = "Chain_"				
		elseif(input2 == "viny") then
			GuardLine.Settings.OutTexturePack = "Viny_"			
			GuardLine.Settings.InTexturePack = "Viny_"		
		else
			EA_ChatWindow.Print(L"Input frame for GuardLine| options: modern, classic, small, dots, chain, viny (Current frame: Out:"..towstring(OutTexturePack)..L", in:"..towstring(InTexturePack)..L")")
			return
		end
	DynamicImageSetTexture ("GuardLineLineLine", GuardLine.Settings.OutTexturePack.."GuardLineLine", 0, 0)
	DynamicImageSetTexture ("GuardLineOffGuardLineLine", GuardLine.Settings.InTexturePack.."GuardLineLine2", 0, 0)
	
	elseif (input1 == "inframe") then
		if(input2 == "modern") then
			GuardLine.Settings.InTexturePack = "Modern_"
		elseif(input2 == "classic") then
			GuardLine.Settings.InTexturePack = "Classic_"
		elseif(input2 == "small") then
			GuardLine.Settings.InTexturePack = "Small_"
		elseif(input2 == "dots") then		
			GuardLine.Settings.InTexturePack = "Dots_"
		elseif(input2 == "chain") then		
			GuardLine.Settings.InTexturePack = "Chain_"						
		elseif(input2 == "viny") then		
			GuardLine.Settings.InTexturePack = "Viny_"	
		else
			EA_ChatWindow.Print(L"Input In frame for GuardLine| options: modern, classic, small, dots, chain, viny (Current frame: in:"..towstring(InTexturePack)..L")")
			return
		end
	DynamicImageSetTexture ("GuardLineOffGuardLineLine", GuardLine.Settings.InTexturePack.."GuardLineLine2", 0, 0)
	elseif (input1 == "outframe") then
		if(input2 == "modern") then
			GuardLine.Settings.OutTexturePack = "Modern_"			
		elseif(input2 == "classic") then
			GuardLine.Settings.OutTexturePack = "Classic_"			
		elseif(input2 == "small") then
			GuardLine.Settings.OutTexturePack = "Small_"
		elseif(input2 == "dots") then
			GuardLine.Settings.OutTexturePack = "Dots_"					
		elseif(input2 == "chain") then
			GuardLine.Settings.OutTexturePack = "Chain_"		
		elseif(input2 == "viny") then
			GuardLine.Settings.OutTexturePack = "Viny_"		
		else
			EA_ChatWindow.Print(L"Input Out frame for GuardLine| options: modern, classic, small, dots, chain, viny (Current frame: Out:"..towstring(OutTexturePack)..L")")
			return
		end
	DynamicImageSetTexture ("GuardLineLineLine", GuardLine.Settings.OutTexturePack.."GuardLineLine", 0, 0)	
	elseif (input1 == "reset") then
		GuardLine.ResetSettings()
	elseif (input1 == "scroll") then
			if (input2 == "") or (input2 == nil) then
				GuardLine.Settings.Scroll = not GuardLine.Settings.Scroll
			return
			else
				GuardLine.Settings.ScrollRate = tonumber(input2)*100
			end
			
			
	elseif (input1 == "default") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Default = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Default Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Default.r)..L","..towstring(GuardLine.Settings.Colors.Default.g)..L","..towstring(GuardLine.Settings.Colors.Default.b)..L")")
		end	
	elseif (input1 == "close") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Close = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Close Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Close.r)..L","..towstring(GuardLine.Settings.Colors.Close.g)..L","..towstring(GuardLine.Settings.Colors.Close.b)..L")")
		end				
	elseif (input1 == "mid") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Mid = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Mid Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Mid.r)..L","..towstring(GuardLine.Settings.Colors.Mid.g)..L","..towstring(GuardLine.Settings.Colors.Mid.b)..L")")
		end	
	elseif (input1 == "far") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Far = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Far Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Far.r)..L","..towstring(GuardLine.Settings.Colors.Far.g)..L","..towstring(GuardLine.Settings.Colors.Far.b)..L")")
		end	
	elseif (input1 == "distant") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Distant = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Distant Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Distant.r)..L","..towstring(GuardLine.Settings.Colors.Distant.g)..L","..towstring(GuardLine.Settings.Colors.Distant.b)..L")")
		end	
	elseif (input1 == "dead") then
		if input2 ~= nil then
			local Color_r,Color_g,Color_b = input2:match("(%d+),(%d+),(%d+)") or 255,255,255
			GuardLine.Settings.Colors.Dead = {r=Color_r,g=Color_g,b=Color_b}
		else
			EA_ChatWindow.Print(L"Input Dead Color for GuardLine in r,g,b format (Current Color: "..towstring(GuardLine.Settings.Colors.Dead.r)..L","..towstring(GuardLine.Settings.Colors.Dead.g)..L","..towstring(GuardLine.Settings.Colors.Dead.b)..L")")
		end	
	else
		EA_ChatWindow.Print(L"\nGuardline Ver:"..towstring(Version)..L"\n Options for GuardLine:\n /GuardLine frame <framename>\n /GuardLine inframe <framename>\n /GuardLine outframe <framename>\n /GuardLine offset <number>\n /GuardLine alpha <number>\n /GuardLine scale <number>\n /GuardLine scroll\n /GuardLine range\n /GuardLine reset")
	return
	end
	--GuardLine.Settings.ScrollRate
end

function GuardLine.FakeGuard(input)
	if (input == "out") then
		LibGuard.FakeGuarding = not LibGuard.FakeGuarding
		GuardLine.Libguard_Toggle(3,"FakeGuardOut",nil)
	elseif (input == "in") then
		LibGuard.FakeGuarded = not LibGuard.FakeGuarded
		LibGuard.registeredGuards = {}
	end
	return
end


function GuardLine.ResetSettings()
local ScreenWidthX,ScreenHeightY = GetScreenResolution()
WindowRestoreDefaultSettings("GuardLineLine")
WindowRestoreDefaultSettings("GuardLineSelfWindow")
WindowRestoreDefaultSettings("GuardLineTargetWindow")
WindowRestoreDefaultSettings("GuardLineOffGuardSelfWindow")
WindowRestoreDefaultSettings("GuardLineOffGuardTargetWindow")
WindowRestoreDefaultSettings("GuardLineOffGuardLine")


GuardLine.Settings = {
	X=ScreenWidthX/2,
	Y=ScreenHeightY/2,
	version = Version,
	AnchorOffset = 80,
	Scroll = true,
	ScrollRate = 100,
	Alpha = 1,
	Range = true,
	Scale=1,
	OutTexturePack = "Modern_",
	InTexturePack = "Modern_",
	Colors = {
		Default = {r=255,g=75,b=200},
		Close = {r=50,g=255,b=50},
		Mid = {r=255,g=175,b=10},
		Far = {r=255,g=50,b=50},
		Distant = {r=125,g=125,b=125},
		Dead = {r=175,g=175,b=175}
	}
}
end