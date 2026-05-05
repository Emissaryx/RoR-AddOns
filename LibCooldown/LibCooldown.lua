if LibCooldown then return end
LibCooldown = {abilities={},items={},registeredAbilityCallbacks={},registeredItemCallbacks={},registeredActionCallbacks={},globalCooldown=true,isDebugging=false}
local toggled=false
LibCooldown.Callback=WindowSetShowing
--local libCooldownIsDebugging=false
-- TODO: make this local in public release !!!
local stances={}
function LibCooldown.WindowSetShowing(p1,p2)
	print("p1: "..tostring(p1))
	print("p2: "..tostring(p2))
	return LibCooldown.Callback(p1,p2)
end
local function print(line)
	if LibCooldown.isDebugging then
		EA_ChatWindow.Print(towstring(line))
	end
end

function LibCooldown.FillStances()
	stances={}
	for k,v in pairs(GetAbilityTable(1)) do
		if v.stanceOrder ~= 0 then
			stances[k]=v
		end
	end
end
function LibCooldown.AbilityIsStance(AbilityId)
	return (stances[AbilityId]~=nil)
end
function LibCooldown.RegisterAbilityCallback(callbackFunction)
	if type(callbackFunction)=="function" then
		LibCooldown.registeredAbilityCallbacks[tostring(callbackFunction)]=callbackFunction
	end
end
function LibCooldown.RegisterItemCallback(callbackFunction)
	if type(callbackFunction)=="function" then
		LibCooldown.registeredItemCallbacks[tostring(callbackFunction)]=callbackFunction
	end
end
function LibCooldown.Pcall(command,...)
        local success, errmsg = pcall(command,...)
        if not success then
            EA_ChatWindow.Print(L"LibCooldown got an error from a registered function:")
            EA_ChatWindow.Print(towstring(errmsg))
        end
end


function LibCooldown.UnRegisterAbilityCallback(callbackFunction)
	LibCooldown.registeredAbilityCallbacks[tostring(callbackFunction)]=nil
end
function LibCooldown.UnRegisterItemCallback(callbackFunction)
	LibCooldown.registeredAbilityCallbacks[tostring(callbackFunction)]=nil
end


function LibCooldown.UseGlobalCooldown(var)
	LibCooldown.globalCooldown=(var==true)
end



function LibCooldown.SetStancesOnCooldown()
	for abilityId,stance in pairs(stances) do
		LibCooldown.AddAbilityCooldown(abilityId,stance.cooldown,stance.cooldown)
	end
end
function LibCooldown.AddAbilityCooldown(abilityId,cooldownTimeLeft,totalCooldownTime,isGlobal)
	LibCooldown.abilities[abilityId]={cooldownTimeLeft,totalCooldownTime,isGlobal}
	for k,v in pairs(LibCooldown.registeredAbilityCallbacks) do
		--v(abilityId,true)
		LibCooldown.Pcall(v,abilityId,true,isGlobal)
	end
end
function LibCooldown.AddItemCooldown(uniqueID,cooldownTimeLeft,totalCooldownTime,isGlobal)
	LibCooldown.items[uniqueID]={cooldownTimeLeft,totalCooldownTime,isGlobal}
	for k,v in pairs(LibCooldown.registeredItemCallbacks) do
		--v(uniqueID,true)
		LibCooldown.Pcall(v,uniqueId,true,isGlobal)
	end
end
function LibCooldown.RemoveAbilityCooldown(abilityId)
	LibCooldown.abilities[abilityId]=nil
	for k,v in pairs(LibCooldown.registeredAbilityCallbacks) do
		--v(abilityId,false)
		LibCooldown.Pcall(v,abilityId,false)
	end
end
function LibCooldown.RemoveItemCooldown(uniqueID)
	LibCooldown.items[uniqueID]=nil
	for k,v in pairs(LibCooldown.registeredItemCallbacks) do
		--v(uniqueID,false)
		LibCooldown.Pcall(v,uniqueId,false)
	end
end


function LibCooldown.Hook()
	WindowSetShowing=LibCooldown.WindowSetShowing
end

function LibCooldown.PrintAbilities()
	print("--your abilities--")
	for k,v in pairs(GetAbilityTable(1)) do
		print(k..": "..tostring(v.name))
	end
end
function LibCooldown.PrintTable(t,space)
	if type(t) ~= "table" then
		print("Error in PrintTable: t is not a table")
		return
	end
	if not space then space = "" end
	for k,v in pairs(t) do
		if type(v)=="table" then
			print(space..tostring(k)..": ")
			LibCooldown.PrintTable(v,space.."  ")
		else
			print(space..tostring(k)..": ("..tostring(type(v))..") "..tostring(v))
		end
	end
end
function LibCooldown.PrintVariable(variable,variablename)
	print(variablename..": ("..type(variable)..") "..tostring(variable))
end
function LibCooldown.PrintAbility(abilityId)
	LibCooldown.PrintTable(GetAbilityData(abilityId))
end

function LibCooldown.GetAbilityEnabledState(abilityId) --returns: isEnabled, isTargetValid

end

function LibCooldown.FindItemBy_uniqueID(itemId)
	local items=GetInventoryItemData()
	for k,v in pairs(items) do
		--if(v.id==itemId) then
		if(v.uniqueID==itemId) then
			return v
		end
	end
end
function LibCooldown.FindItemBy_id(itemId)
	local items=GetInventoryItemData()
	for k,v in pairs(items) do
		--if(v.id==itemId) then
		if(v.id==itemId) then
			return v
		end
	end
end
function LibCooldown.FindItemBy_reference(itemId)
	local items=GetInventoryItemData()
	for k,v in pairs(items) do
		--if(v.id==itemId) then
		if(v.bonus[1].reference==itemId) then
			return v
		end
	end
end



function LibCooldown.PlayerBeginCastProxy (abilityId, isChanneledSpell, desiredCastTime, averageLatency)
	LibCooldown.AddGlobalCooldowns()
	if not ((abilityId==245) or (abilityId==2490)) then --fleeeee or autoattack
		LibCooldown.LastAbility=abilityId
	end
	print ("begin casting ("..abilityId..") : "..tostring(GetAbilityData(abilityId).name))
	
	if ((desiredCastTime==0) or (isChanneledSpell)) then --HACK: instant cast do not trigger playerendcast and channeled casts maybe instantly begin with their cooldown(not sure about that)
		LibCooldown.PlayerEndCastProxy (false)
	end
	--print ("isActive"..tostring(GetAbilityData(abilityId).isActive))
	--print ("isChanneledSpell"..tostring(isChanneledSpell))
end
function LibCooldown.AddGlobalCooldowns()
			if LibCooldown.globalCooldown then
				for k,v in pairs(GetAbilityTable(1)) do
					--if (not LibCooldown.AbilityIsStance(k)) or (LibCooldown.abilities[k]==nil) then
					if (LibCooldown.abilities[k]==nil) then
						LibCooldown.AddAbilityCooldown(k,1,1,true)
					end
					--end
				end
			end
end
function LibCooldown.PlayerEndCastProxy (fail)
	local abilityId=LibCooldown.LastAbility
	LibCooldown.LastAbility=nil
	if not abilityId then return end
	print ("end casting ("..abilityId..") : "..tostring(GetAbilityData(abilityId).name))
	if fail then
		print ("fail!")
	else
		local abilityData=GetAbilityData(abilityId)
		--LibCooldown.abilities[abilityData.name]=abilityData.cooldown
		if abilityData.id and abilityData.id ~=nil then
			--LibCooldown.abilities[abilityId]={abilityData.cooldown,abilityData.cooldown}
			LibCooldown.AddAbilityCooldown(abilityId,abilityData.cooldown,abilityData.cooldown)
			if LibCooldown.AbilityIsStance(abilityId) then
				LibCooldown.SetStancesOnCooldown()
			end
		else
			local itemData=LibCooldown.FindItemBy_reference(abilityId)
			if itemData then
				--LibCooldown.items[itemData.uniqueID]={itemData.bonus[1].cooldownTimeLeft,itemData.bonus[1].totalCooldownTime}
				LibCooldown.AddItemCooldown(itemData.uniqueID,itemData.bonus[1].cooldownTimeLeft,itemData.bonus[1].totalCooldownTime)
			end
		end



	end
end
function LibCooldown.GetAbilityCooldown(abilityId)
	local cooldown=LibCooldown.abilities[abilityId]
	if cooldown==nil then
		return 0,0
	end
	if cooldown[1] then
		return cooldown[1],cooldown[2],(cooldown[3]==true)
	else
		return 0,0
	end
end
function LibCooldown.GetItemCooldown(uniqueID)
	local cooldown=LibCooldown.items[uniqueID]
	if cooldown~=nil then
		return cooldown[1],cooldown[2],(cooldown[3]==true)
	end
	
	--print("GetItemCooldown called: "..itemId)
	--local itemData=DataUtils.FindItem(itemId)
	

	local itemData=LibCooldown.FindItemBy_uniqueID(uniqueID)
	if not itemData then return 0,0 end
	local bonusData=itemData.bonus[1]
	if not bonusData then return 0,0 end
	if bonusData.cooldownTimeLeft==nil then return 0,0 end
	
	
	--[[if( bonusData.type == GameDefs.ITEMBONUS_USE and 
            bonusData.cooldownTimeLeft and
            bonusData.cooldownTimeLeft > 0 and
            bonusData.totalCooldownTime and
            bonusData.totalCooldownTime > 0 
           ) then]]--
	--	print("returning itemcooldown:"..bonusData.cooldownTimeLeft)
	if bonusData.cooldownTimeLeft>0 then
		--LibCooldown.items[uniqueID]={bonusData.cooldownTimeLeft,bonusData.totalCooldownTime}
		LibCooldown.AddItemCooldown(uniqueID,bonusData.cooldownTimeLeft,bonusData.totalCooldownTime)
	end
	return bonusData.cooldownTimeLeft,bonusData.totalCooldownTime
	--else
	--	return 0,0
	--end
end
function LibCooldown.GetActionCooldown(actionId,actionType)
		local actionType=actionType
		if actionType==nil then
			local isItem=DataUtils.FindItem(actionId)
			if isItem then
				actionType=GameData.PlayerActions.USE_ITEM
			else
				actionType=PlayerActions.DO_ABILITY
			end
		end
		local cooldownfunctions={
			[GameData.PlayerActions.DO_ABILITY] = function (id)
					return LibCooldown.GetAbilityCooldown (id) 
				end,
			[GameData.PlayerActions.USE_ITEM]=function (id)
					return LibCooldown.GetItemCooldown(id)
				end,
		}
		local callme=cooldownfunctions[actionType]
		if callme then
			return callme(actionId)
		else
			return 0,0
		end
end
function LibCooldown.OnUpdate(elapsed)
	for k,v in pairs(LibCooldown.abilities) do
		local remaining=v[1]-elapsed
		if remaining<0 then
			--LibCooldown.abilities[k]=nil
			LibCooldown.RemoveAbilityCooldown(k)
			print("cooldown for "..tostring(k).." ran out")
		else
			LibCooldown.abilities[k][1]=remaining
		end
	end
	for k,v in pairs(LibCooldown.items) do
		local remaining=v[1]-elapsed
		if remaining<0 then
			--LibCooldown.items[k]=nil
			LibCooldown.RemoveItemCooldown(k)
			print("cooldown for item "..tostring(k).." ran out")
		else
			LibCooldown.items[k][1]=remaining
		end
	end
end
function LibCooldown.AbilityToggled(abilityId, isActive)
	if abilityId==2490 then return end
	LibCooldown.LastAbility=abilityId
	print ("you toggled the ability ("..abilityId..") : "..tostring(GetAbilityData(abilityId).name))
	if not isActive then
		local abilityData=GetAbilityData(abilityId)
		--LibCooldown.abilities[abilityId]={abilityData.cooldown,abilityData.cooldown}
		LibCooldown.AddAbilityCooldown(abilityId,abilityData.cooldown,abilityData.cooldown)
	end
end
function LibCooldown.Initialize()
	LibCooldown.FillStances()
	RegisterEventHandler(SystemData.Events.PLAYER_ABILITY_TOGGLED,"LibCooldown.AbilityToggled")
	RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST,"LibCooldown.PlayerBeginCastProxy")
	RegisterEventHandler(SystemData.Events.PLAYER_END_CAST,"LibCooldown.PlayerEndCastProxy")	
end
