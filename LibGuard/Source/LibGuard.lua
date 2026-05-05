local Version = 1.7
local IdToken = "\77\97\114\116\121\114\115\32\83\113\117\97\114\101"

if LibGuard == nil then LibGuard = {} end
if LibGuard.LatestGuardName == nil then LibGuard.LatestGuardName = nil end
if LibGuard.GuarderData == nil then LibGuard.GuarderData = {Name=L"",IsGuarding = false,XGuard = false,ID=0,Career=0,Range = -1,distance= -1} end
if LibGuard.UsePet == nil then LibGuard.UsePet = true end



	local MAX_MAP_POINTS = 511
	local DISTANCE_FIX_COEFFICIENT = 1 / 1.06
	local MapPointTypeFilter = {
		[SystemData.MapPips.PLAYER] = true,
		[SystemData.MapPips.GROUP_MEMBER] = true,
		[SystemData.MapPips.WARBAND_MEMBER] = true,
		[SystemData.MapPips.DESTRUCTION_ARMY] = true,
		[SystemData.MapPips.ORDER_ARMY] = true
	}	
	

LibGuard.registeredGuards = {}
LibGuard.registered_GUARD_UPDATE_Callbacks={}
LibGuard.StateTimer = 0.25
local GuardThrottle = 0
local GUARDED_APPLY_ID = 1			--when another player add guard to you
local GUARDED_REMOVE_ID = 2			--when another players guard removes from you
local GUARDING_APPLY_ID = 3			--when you add guard to another player
local GUARDING_REMOVE_ID = 4			--when your guard removes from another player

local PlayerName = wstring.sub( GameData.Player.name,1,-3 )
local SEND_BEGIN = 1
local SEND_FINISH = 2

local GuardAbilityIds =
{
	[1008] = true,	-- Guard
	[1363] = true,	-- Guard
	[8013] = true,	-- Guard
	[8325] = true,	-- Guard
	[9008] = true,	-- Guard
	[9325] = true,	-- Guard	
	[1674] = true	-- Save Da Runts
}


function LibGuard.Init()

LibGuard.FakeGuarded = false
RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "LibGuard.StartCast")

ror_PacketHandling.Register("LibGuard",LibGuard.GuardPacket)
--RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "LibGuard.UpdateEffect")
--RegisterEventHandler(TextLogGetUpdateEventId("Chat"), "LibGuard.OnChatLogUpdated")	
RegisterEventHandler (SystemData.Events.PLAYER_PET_HEALTH_UPDATED,"LibGuard.UpdatePetHealthProxy")
RegisterEventHandler( SystemData.Events.GROUP_PLAYER_ADDED,"LibGuard.GROUP_UPDATED" )
RegisterEventHandler( SystemData.Events.GROUP_LEAVE, "LibGuard.GROUP_UPDATED")
RegisterEventHandler( SystemData.Events.SCENARIO_GROUP_JOIN, "LibGuard.GROUP_UPDATED")
RegisterEventHandler( SystemData.Events.SCENARIO_GROUP_LEAVE, "LibGuard.GROUP_UPDATED")
RegisterEventHandler( SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "LibGuard.GROUP_UPDATED")
RegisterEventHandler( SystemData.Events.SCENARIO_END, "LibGuard.GROUP_UPDATED")


--Using a StateMachine for updates instead of manual timers
LibGuard.stateMachineName = "LibGuard"
LibGuard.state = {[SEND_BEGIN] = { handler=nil,time=LibGuard.StateTimer,nextState=SEND_FINISH } , [SEND_FINISH] = { handler=LibGuard.UpdateStateMachine,time=LibGuard.StateTimer,nextState=SEND_BEGIN, } , }
	if (LibSlash ~= nil) then
		LibSlash.RegisterSlashCmd("guardtest", TestGuard)
	end
LibGuard.StartMachine()
LibGuard.FakeGuarded = false
LibGuard.FakeGuarding = false
end

function LibGuard.UpdatePetHealthProxy(healthPool)
	if LibGuard.UsePet == true then
	local Petname = wstring.gsub(LibGuard.FixString(GameData.Player.Pet.name),LibGuard.FixString(GameData.Player.name)..L"'s","")
		if healthPool > 0 then		
				LibGuard.FakeGuarding = true
				GuardLine.Libguard_Toggle(3,Petname,nil)
		else
				LibGuard.FakeGuarding = false
				LibGuard.UpdateEffect()
		end
	elseif 	LibGuard.UsePet == false then
		LibGuard.FakeGuarding = false
		LibGuard.UpdateEffect()
	end
end

function LibGuard.OnShutdown()	
UnregisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "LibGuard.StartCast")
--UnregisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "LibGuard.UpdateEffect")
--UnregisterEventHandler(TextLogGetUpdateEventId("Chat"), "LibGuard.OnChatLogUpdated")	
UnregisterEventHandler (SystemData.Events.PLAYER_PET_HEALTH_UPDATED,"LibGuard.UpdatePetHealthProxy")
UnregisterEventHandler( SystemData.Events.GROUP_PLAYER_ADDED,"LibGuard.GROUP_UPDATED" )
UnregisterEventHandler( SystemData.Events.GROUP_LEAVE, "LibGuard.GROUP_UPDATED")
UnregisterEventHandler( SystemData.Events.SCENARIO_GROUP_JOIN, "LibGuard.GROUP_UPDATED")
UnregisterEventHandler( SystemData.Events.SCENARIO_GROUP_LEAVE, "LibGuard.GROUP_UPDATED")
UnregisterEventHandler( SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "LibGuard.GROUP_UPDATED")
UnregisterEventHandler( SystemData.Events.SCENARIO_END, "LibGuard.GROUP_UPDATED")	
end


function LibGuard.StartMachine()
	local stateMachine = TimedStateMachine.New( LibGuard.state,SEND_BEGIN)
	TimedStateMachineManager.AddStateMachine( LibGuard.stateMachineName, stateMachine )
end

--Detect whenever you cast Guard ability
function LibGuard.StartCast(abilityId, isChannel, desiredCastTime, holdCastBar)
--	TargetInfo:UpdateFromClient()
	if TargetInfo:UnitName("selffriendlytarget") ~= nil then
		if (GuardAbilityIds[abilityId]) == true then	
		local ToName = wstring.sub(towstring(TargetInfo:UnitName("selffriendlytarget")),1,-3 )
		local UnitID = TargetInfo:UnitEntityId("selffriendlytarget")
		LibGuard.GuarderData = {}
		LibGuard.GuarderData.Name = wstring.sub(towstring(TargetInfo:UnitName("selffriendlytarget")),1,-3 )
		LibGuard.GuarderData.ID=UnitID
		LibGuard.GuarderData.Career=LibGuard.GetIdFromName(ToName,2)
		LibGuard.GuarderData.distance= -1
		LibGuard.GuarderData.Range = -1
		LibGuard.GuarderData.IsGuarding = true	
		--LibGuard.GuarderData = {Name=ToName,,ID=UnitID,Career=LibGuard.GetIdFromName(ToName,2),distance= -1}
		LibGuard.GuarderData.XGuard=(Check_XGuard())	
		LibGuard.DoCallback(GUARDING_APPLY_ID,LibGuard.GuarderData.Name,LibGuard.GuarderData.ID)
		GuardThrottle = 2
		end
		
	end
end

--Checks if you are CrossGuarding (returns true if Crossguarding is detected)
function Check_XGuard()
if LibGuard.GuarderData.Name ~= L"" then
	for k, v in pairs( LibGuard.registeredGuards ) do
		if (LibGuard.registeredGuards[k].Name) == LibGuard.GuarderData.Name then
		return true
		end	
		end
	end
	
	if LibGuard.FakeGuarding == true and LibGuard.FakeGuarded == true and LibGuard.registeredGuards["FakeGuardIn"] ~= nil then
		if LibGuard.GuarderData.ID == LibGuard.registeredGuards["FakeGuardIn"].ID then
		return true
		end
	end
	
return false	
end

--If your guard had been removed, clear the GuarderData
function LibGuard.UpdateEffect(BuffTable)
if LibGuard.FakeGuarding == true then

else
		local BuffList = GetBuffs(GameData.BuffTargetType.SELF)
		local IsGuaring = false
		if BuffList ~= nil then
			for k,v in pairs(BuffList) do			
						if (GuardAbilityIds[BuffList[k].abilityId]) == true then		
							if LibGuard.GuarderData.IsGuarding == true and BuffList[k].castByPlayer then	
								IsGuaring = true
								break
							end	
						end	
				end
				
		
		if IsGuaring == false and LibGuard.GuarderData.IsGuarding == true and LibGuard.GuarderData.Name ~= nil and GuardThrottle <= 0 then		
		local NameProxy = LibGuard.GuarderData.Name
		LibGuard.GuarderData.distance = -1
		LibGuard.GuarderData.Range = -1
		LibGuard.GuarderData.IsGuarding = false
		LibGuard.GuarderData.Name = L""
		LibGuard.GuarderData.Career = 0
		LibGuard.GuarderData.XGuard=false	
		LibGuard.DoCallback(GUARDING_REMOVE_ID,NameProxy,0)
		end	
	end	
end	
end

--Function for getting Player Information from name in the party / warband / scenario
--State Returns: 1)- Player Object ID , 2)- Player Career Line , 3)- Player Data table
function LibGuard.GetIdFromName(GName,state)
local Gname = GName or ""
local state = tonumber(state) or 0


if LibGuard.FakeGuarded == true then
if state == 0 or state == 3 then
return  {
					zoneNum = GameData.Player.zone,
					isDistant = false,					
					healthPercent = 100,
					online= true,
					name = L"FakeGuardIn",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Chosen",
					careerLine = 5				
					}

elseif state == 1 then
	return TargetInfo.m_Units.selffriendlytarget.entityid
elseif state == 2 then
	return 5
end


end

	--get Warband Data
	if IsWarBandActive() and (not GameData.Player.isInScenario) and (not GameData.Player.isInSiege) then
	local warband = PartyUtils.GetWarbandData()	
		for _, party in ipairs( warband ) do
			for _, member in ipairs( party.players ) do						
				if tostring(Gname) == tostring(LibGuard.FixString (member.name)) then
					if state == 1 then
						if member.name ~= L"" then
							return (member.worldObjNum)
						else					
							break
						end
					elseif state == 2 then
						if member.name ~= L"" then
							return (member.careerLine)
						else					
							break
						end
					elseif state == 3 then
						if member.name ~= L"" then
							if member ~= nil then
							return (member)
							else
							return {}
							end
						else					
							break
						end	
					end
				end
			end
		end	
	end	
	
	--get Party/Scenario data
	if ((not IsWarBandActive() and PartyUtils.IsPartyActive()) or (GameData.Player.isInScenario) or (GameData.Player.isInSiege))then
	local groupData=PartyUtils.GetPartyData()
		for index,memberData in ipairs(groupData) do 
			if tostring(Gname) == tostring(LibGuard.FixString(memberData.name)) then
				if state == 1 then
					if memberData.name ~= L"" then
						return (memberData.worldObjNum)		
					else					
						break
					end
				elseif state == 2 then
					if memberData.name ~= L"" then
						return (memberData.careerLine)		
					else					
						break
					end			
				elseif state == 3 then
					if memberData.name ~= L"" then
						return (memberData)		
					else					
						break
					end								
				end
			end
		end
	end
return 0	
end


--User Register Functions to be run when guard has been applyed to you
function LibGuard.Register_Callback(callbackFunction)
	if type(callbackFunction)=="function" then
		d(L"GUARD_UPDATE Callback Registered")
		EA_ChatWindow.Print(L"GUARD_UPDATE Callback Registered")	
		if LibGuard.registered_GUARD_UPDATE_Callbacks[tostring(callbackFunction)] == nil then
			LibGuard.registered_GUARD_UPDATE_Callbacks[tostring(callbackFunction)]=callbackFunction									
		else
			EA_ChatWindow.Print(L"Callback Has Already Been Registered")	
		end
	end
end


function LibGuard.Unregister_Callback(callbackFunction)
	if type(callbackFunction)=="function" then
		d(L"GUARD_UPDATE Callback Unregisterd")	
		EA_ChatWindow.Print(L"GUARD_UPDATE Callback Unregisterd")
		LibGuard.registered_GUARD_UPDATE_Callbacks[tostring(callbackFunction)]=nil				
	end
	
end


--Run the registered functions when the action is fired
function LibGuard.DoCallback(state,GName,GuardedID,...)
		for k,v in pairs(LibGuard.registered_GUARD_UPDATE_Callbacks) do
			LibGuard.Pcall(v,state,GName,GuardedID,...)			
		end			
end

--Execute the callback Functions
function LibGuard.Pcall(command,...)
local success, errmsg = pcall(command,...)
	if not success then
		EA_ChatWindow.Print(L"LibGuard got an error from a registered function:")
		EA_ChatWindow.Print(towstring(errmsg))
	end
return
end

--guard confirmation on channel 9
function LibGuard.OnChatLogUpdated(updateType, filterType)
	if( updateType == SystemData.TextLogUpdate.ADDED ) then 			
		if filterType == SystemData.ChatLogFilters.CHANNEL_9 then	
			local _, filterId, text = TextLogGetEntry( "Chat", TextLogGetNumEntries("Chat") - 1 ) 
			if text:find(L"LibGuard") then		
			local SPLIT_TEXT = StringSplit(tostring(text), ":")
				if SPLIT_TEXT[2] == "Apply" then
					LibGuard.RegisterGuard(SPLIT_TEXT[3])
				elseif SPLIT_TEXT[2] == "Remove" then
					LibGuard.UnregisterGuard(SPLIT_TEXT[3])
				end
			end
		end
	end
end


function LibGuard.GuardPacket(text)	
			local SPLIT_TEXT = StringSplit(tostring(text),":")
				if SPLIT_TEXT[2] == "Apply" then
					LibGuard.RegisterGuard(SPLIT_TEXT[3])
				elseif SPLIT_TEXT[2] == "Remove" then
					LibGuard.UnregisterGuard(SPLIT_TEXT[3])
				end
end


--A guard has been applied to the player, Do the Guard Buff assigning to the player		
function LibGuard.RegisterGuard(GName,...)
local GuardedName = tostring(GName)
local GuardedID = LibGuard.GetIdFromName(GuardedName,1)
	if LibGuard.registeredGuards[GuardedName] == nil then
		LibGuard.registeredGuards[GuardedName] = {}
		LibGuard.registeredGuards[GuardedName].Name = towstring(GuardedName)			
		LibGuard.LatestGuardName = towstring(GuardedName)
		LibGuard.DoCallback(GUARDED_APPLY_ID,GuardedName,GuardedID,...)
	end		
LibGuard.GuarderData.XGuard=(Check_XGuard())	
LibGuard.UpdateStateMachine()
end

--This runs a StateMachine when every n'th LibGuard.StateTimer counter
function LibGuard.UpdateStateMachine()

	
				if LibGuard.FakeGuarded == true then
					LibGuard.registeredGuards={
					["FakeGuardIn"]={distance = 29,
					Name=L"FakeGuardIn",
					Range = 29,
					ID = TargetInfo.m_Units.selffriendlytarget.entityid,
					Career = 1,
					Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = 100,
					online= true,
					name = L"FakeGuardIn",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 1				
					}
				},
				["FakeGuardIn2"]={distance = 35,
					Name=L"FakeGuardIn_2",
					Range = 35,
					ID = TargetInfo.m_Units.selffriendlytarget.entityid,
					Career = 10,
					Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = 100,
					online= true,
					name = L"FakeGuardIn_2",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 10				
					}
				},
				["FakeGuardIn3"]={distance = 55,
					Name=L"FakeGuardIn_3",
					Range = 55,
					ID = TargetInfo.m_Units.selffriendlytarget.entityid,
					Career = 5,
					Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = 100,
					online= true,
					name = L"FakeGuardIn_3",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 5				
					}
				},
				["FakeGuardIn4"]={distance = 100,
					Name=L"FakeGuardIn_4",
					Range = 100,
					ID = TargetInfo.m_Units.selffriendlytarget.entityid,
					Career = 13,
					Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = 0,
					online= true,
					name = L"FakeGuardIn_4",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 13				
					}
				},					
				["FakeGuardIn5"]={distance = 999,
					Name=L"FakeGuardIn_5",
					Range = 999,
					ID = TargetInfo.m_Units.selffriendlytarget.entityid,
					Career = 17,
					Info = {
					zoneNum = GameData.Player.zone,
					isDistant = true,
					healthPercent = 100,
					online= true,
					name = L"FakeGuardIn_5",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 17				
					}
				},				
				}
				end
				
				if LibGuard.FakeGuarding == true then
				
					if (GameData.Player.Pet.healthPercent > 0) then
					local Petname = wstring.gsub(LibGuard.FixString(GameData.Player.Pet.name),LibGuard.FixString(GameData.Player.name)..L"'s","")
					LibGuard.GuarderData.IsGuarding = true
					LibGuard.GuarderData.Name = Petname
					LibGuard.GuarderData.distance = -1
					LibGuard.GuarderData.Range = -1
					LibGuard.GuarderData.ID = GameData.Player.Pet.objNum	
					LibGuard.GuarderData.Career = 1
					LibGuard.GuarderData.Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = GameData.Player.Pet.healthPercent,
					online= true,
					name = Petname,
					worldObjNum = GameData.Player.Pet.objNum,
					careerName = L"Pet",
					careerLine = 1		
					}
	
					else
					if LibGuard.GuarderData.IsGuarding == false then
					LibGuard.GuarderData.IsGuarding = true
					LibGuard.GuarderData.Name = L"FakeGuardOut"
					LibGuard.GuarderData.distance = 29
					LibGuard.GuarderData.Range = 29
					LibGuard.GuarderData.ID = TargetInfo.m_Units.selffriendlytarget.entityid	
					LibGuard.GuarderData.Career = 1
					LibGuard.GuarderData.Info = {
					zoneNum = GameData.Player.zone,
					isDistant = false,
					healthPercent = 100,
					online= true,
					name = L"FakeGuardOut",
					worldObjNum = TargetInfo.m_Units.selffriendlytarget.entityid,
					careerName = L"Pet",
					careerLine = 1				
					}	
					end	
					end
				end				
		


if GuardThrottle > 0 then GuardThrottle = GuardThrottle -1 end


if PartyUtils.IsPartyActive() then
--Updates Range and Players Info from other Guardings
	if  LibGuard.registeredGuards and LibGuard.FakeGuarded == false then
		for k, v in pairs( LibGuard.registeredGuards ) do	
					LibGuard.registeredGuards[k].distance = 999
					LibGuard.registeredGuards[k].Range = 999
					LibGuard.registeredGuards[k].ID = LibGuard.GetIdFromName(LibGuard.registeredGuards[k].Name,1)
					LibGuard.registeredGuards[k].Career = LibGuard.GetIdFromName(LibGuard.registeredGuards[k].Name,2)	
					LibGuard.registeredGuards[k].Info = LibGuard.GetIdFromName(LibGuard.registeredGuards[k].Name,3)
			for i = 1, MAX_MAP_POINTS do
				local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", i)
				if (not mpd or not mpd.name) then continue end							
				--not MapPointTypeFilter[mpd.pointType] or
				local name = LibGuard.FixString((mpd.name))
				if name == LibGuard.registeredGuards[k].Name then
					LibGuard.registeredGuards[k].distance = math.floor (mpd.distance * DISTANCE_FIX_COEFFICIENT) 
					LibGuard.registeredGuards[k].Range = mpd.distance * DISTANCE_FIX_COEFFICIENT
				end			
			end
		end
	end	
--Updates Range and Players Info from Your guard
	if LibGuard.GuarderData.IsGuarding and LibGuard.FakeGuarding == false then
			for i = 1, MAX_MAP_POINTS do
				local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", i)
				if (not mpd or not mpd.name) then continue end							
				--or not MapPointTypeFilter[mpd.pointType]
				local name = LibGuard.FixString((mpd.name))
				if name == LibGuard.GuarderData.Name then
					LibGuard.GuarderData.distance = math.floor (mpd.distance * DISTANCE_FIX_COEFFICIENT)
					LibGuard.GuarderData.Range = mpd.distance * DISTANCE_FIX_COEFFICIENT
					LibGuard.GuarderData.ID = LibGuard.GetIdFromName(name,1)	
					LibGuard.GuarderData.Career = LibGuard.GetIdFromName(name,2)
					LibGuard.GuarderData.Info = LibGuard.GetIdFromName(name,3)
					break					
				end			
			end	
		end	
	end	

if LibGuard.GuarderData.IsGuarding == true then
	LibGuard.UpdateEffect()
end
return		
end

function LibGuard.GetRangeFromName(Name)
			for i = 1, MAX_MAP_POINTS do
				local mpd = GetMapPointData ("EA_Window_OverheadMapMapDisplay", i)
				if (not mpd or not mpd.name) then continue end							
				--or not MapPointTypeFilter[mpd.pointType]
				local name = LibGuard.FixString((mpd.name))
				if name == Name then
					local NameRange = mpd.distance * DISTANCE_FIX_COEFFICIENT
					return NameRange			
				end			
			end	
end

function LibGuard.GROUP_UPDATED()
	for k, v in pairs( LibGuard.registeredGuards ) do
		local Do_Remove = true
			local groupData=PartyUtils.GetPartyData()		
				for index,memberData in ipairs(groupData) do 
					if LibGuard.registeredGuards[k].Name == memberData.name or LibGuard.registeredGuards[k].Name == LibGuard.GuarderData.Name then
					Do_Remove = false
					break
					end
				end								
		if Do_Remove == true then
			LibGuard.UnregisterGuard(LibGuard.registeredGuards[k].Name)						
		end
	end
	LibGuard.UpdateEffect()
end


--Returns a corrected formated player name
function LibGuard.FixString (str)
	if (str == nil) then return nil end
	local str = str
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end	
	return str
end

--A guard has been removed from the player, Do the Guard Unassigning to the player
function LibGuard.UnregisterGuard(GName,...)
local GuardedName = tostring(GName)
	if (LibGuard.registeredGuards[GuardedName].Name) == towstring(GuardedName) then			
		LibGuard.DoCallback(GUARDED_REMOVE_ID,GName,0,...)
		LibGuard.registeredGuards[GuardedName] = nil
	end	
LibGuard.GuarderData.XGuard=(Check_XGuard())	
LibGuard.UpdateStateMachine()
end

--================================================
-- This registers a Test Guard function Example
-- Use /guardtest   or   /script TestGuard()
--================================================

function TestGuard()
	LibGuard.Register_Callback(CB_Update)
	EA_ChatWindow.Print(L"Guard Test Loaded")	
end

function CB_Update(state,GuardedName,GuardedID)
local XGuard = L""

	if (tostring(GuardedName) == tostring(LibGuard.GuarderData.Name)) and Check_XGuard() then
		XGuard = towstring(CreateHyperLink(L"Xguard",L" X-Guard", {55,55,200},{}))..L" Detected!"
	end

--This triggers when anny of the State events happens:
	if state == GUARDED_APPLY_ID then		--when another player add guard to you
		ChatManager.AddChatText( GameData.Player.worldObjNum,towstring(GuardedName)..L" has "..towstring(CreateHyperLink(L"Applied",L"Applied", {30,225,30},{}))..L" a Guard on me"..XGuard)
	elseif state == GUARDING_APPLY_ID then	--when you add guard to another player
		ChatManager.AddChatText( GameData.Player.worldObjNum,L"I have "..towstring(CreateHyperLink(L"Applied",L"Applied", {30,225,30},{}))..L" a Guard on "..towstring(GuardedName)..XGuard)
	elseif state == GUARDED_REMOVE_ID then	--when another players guard removes from you
		ChatManager.AddChatText( GameData.Player.worldObjNum,towstring(GuardedName)..L"s Guard was "..towstring(CreateHyperLink(L"Removed",L"Removed", {255,30,30},{}))..L" from me")
	elseif state == GUARDING_REMOVE_ID then	--when your guard removes from another player
		ChatManager.AddChatText( GameData.Player.worldObjNum,L"My Guard was "..towstring(CreateHyperLink(L"Removed",L"Removed", {255,30,30},{}))..L" from "..towstring(GuardedName))				
	end		
end
