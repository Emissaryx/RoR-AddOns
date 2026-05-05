
-- Originally written by the Ace Team, ported to WAR by Werelds
local ACEDBO_MAJOR, ACEDBO_MINOR = "WAR-AceDBOptions-3.0", 9
local AceDBOptions, oldminor = LibStub:NewLibrary(ACEDBO_MAJOR, ACEDBO_MINOR)

if not AceDBOptions then return end -- No upgrade needed

AceDBOptions.optionTables = AceDBOptions.optionTables or {}
AceDBOptions.handlers = AceDBOptions.handlers or {}


local pairs, ipairs = pairs, ipairs
local tostring = tostring
local WStringToString = WStringToString
local gsub = gsub

local function prepareString(input)

	--d("AceDBOptions local function prepareString(input)")

	-- Convert to string.
	if (type(input) == "wstring") then
		input = WStringToString(input)
	else
		input = tostring(input)
	end

	-- Remove suffix.
	input = input:gsub("%^[fFmM]", "")
	
	-- Done..For now.
	return input
end

local careerLineMap = {}
for k, v in pairs( GameData.CareerLine ) do

	careerLineMap[v] = { Name = CareerNames[v].name }
	
	if( v == 1 or v == 2 or v == 3 or v == 4 or v == 9 or v == 10 or v == 11 
		or v == 12 or v == 17 or v == 18 or v == 19 or v == 20 ) then
		careerLineMap[v].Faction = 1
	else
		careerLineMap[v].Faction = 2
	end
end

-- Storing careerline for use in the keys
local careerLine = GetCareerLineFromId( GameData.Player.career.id )
local realmKey = GameData.Account.ServerName
local charKey = GameData.Player.name .. L" - " .. realmKey
local raceKey = RaceNames[GameData.Player.race.id].name
local classKey = careerLineMap[careerLine].Name
local factionKey = GetRealmName( careerLineMap[careerLine].Faction )

local accountCharKeys = {}
for k,v in pairs( GameData.Account.CharacterSlot ) do
	if( v.Level > 0 ) then
		local idx = k .. " - " .. prepareString( realmKey )
		accountCharKeys[idx] = v.Name .. L" - " .. realmKey
	end	
end

--[[
	Localization of AceDBOptions-3.0
]]
local T = {
	default = "Default",
	intro = "You can change the active database profile, so you can have different settings for every character.",
	reset_desc = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.",
	reset = "Reset Profile",
	reset_sub = "Reset the current profile to the default",
	choose_desc = "You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles.",
	new = "New",
	new_sub = "Create a new empty profile.",
	choose = "Existing Profiles",
	choose_sub = "Select one of your currently available profiles.",
	copy_desc = "Copy the settings from one existing profile into the currently active profile.",
	copy = "Copy From",
	delete_desc = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.",
	delete = "Delete a Profile",
	delete_sub = "Deletes a profile from the database.",
	delete_confirm = "Are you sure you want to delete the selected profile?",
	profiles = "Profiles",
	profiles_sub = "Manage Profiles",
}

-- Quick lookup table again!
local LocaleNameById = {
    [SystemData.Settings.Language.ENGLISH] = "enUS",
}

local LOCALE = LocaleNameById[SystemData.Settings.Language.ENGLISH]

local defaultProfiles
local tmpprofiles = {}

--[[
	getProfileList(db, common, nocurrent)
	
	db - the db object to retrieve the profiles from
	common (boolean) - if common is true, getProfileList will add the default profiles to the return list, even if they have not been created yet
	nocurrent (boolean) - if true then getProfileList will not display the current profile in the list
]]--
local function getProfileList(db, common, nocurrent)

	--d("local function getProfileList(db, common, nocurrent)")

	local profiles = {}
	
	-- copy existing profiles into the table
	local currentProfile = db:GetCurrentProfile()
	
	for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
		if not (nocurrent and v == currentProfile) then 
			profiles[v] = v 
		end
	end
	
	-- add our default profiles to choose from ( or rename existing profiles)
	for k,v in pairs(defaultProfiles) do
		if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
			profiles[k] = v
		end
	end
	
	return profiles
end

--[[
	OptionsHandlerPrototype
	prototype class for handling the options in a sane way
]]
local OptionsHandlerPrototype = {}

--[[ Reset the profile ]]
function OptionsHandlerPrototype:Reset()
	--d("OptionsHandlerPrototype:Reset()")
	self.db:ResetProfile()
end

--[[ Set the profile to value ]]
function OptionsHandlerPrototype:SetProfile(info, value)
	--d('function OptionsHandlerPrototype:SetProfile(info, value)')
	self.db:SetProfile(value)
end

function OptionsHandlerPrototype:GetProfileDisplayName( profile )
	--d("function OptionsHandlerPrototype:GetProfileDisplayName( profile )")
	return accountCharKeys[profile] or nil;
end

--[[ returns the currently active profile ]]
function OptionsHandlerPrototype:GetCurrentProfile()
	--d('function OptionsHandlerPrototype:GetCurrentProfile()')
	return self.db:GetCurrentProfile()
end

--[[ 
	List all active profiles
	you can control the output with the .arg variable
	currently four modes are supported
	
	(empty) - return all available profiles
	"nocurrent" - returns all available profiles except the currently active profile
	"common" - returns all available profiles + some commonly used profiles ("char - realm", "realm", "class", "Default")
	"both" - common except the active profile
]]
function OptionsHandlerPrototype:ListProfiles(info)
	--d('function OptionsHandlerPrototype:ListProfiles(info)')
	local arg = info.arg
	local profiles
	if arg == "common" and not self.noDefaultProfiles then
		profiles = getProfileList(self.db, true, nil)
	elseif arg == "nocurrent" then
		profiles = getProfileList(self.db, nil, true)
	elseif arg == "both" then
		profiles = getProfileList(self.db, (not self.noDefaultProfiles) and true, true)
	else
		profiles = getProfileList(self.db)
	end
	
	return profiles
end

--[[ Copy a profile ]]
function OptionsHandlerPrototype:CopyProfile(info, value)
	--d("function OptionsHandlerPrototype:CopyProfile(info, value)")
	self.db:CopyProfile(value)
end

--[[ Delete a profile from the db ]]
function OptionsHandlerPrototype:DeleteProfile(info, value)
	--d('function OptionsHandlerPrototype:DeleteProfile(info, value)')
	self.db:DeleteProfile(value)
end

--[[ fill defaultProfiles with some generic values ]]
local function generateDefaultProfiles(db)
	--d('local function generateDefaultProfil')
	defaultProfiles = {
		["Default"] 			= T["default"],
		[db.keys.char] 			= charKey,
		[db.keys.realm] 		= realmKey,
		[db.keys.class] 		= classKey,
		[db.keys.race] 			= raceKey,
		[db.keys.faction] 		= factionKey,
		[db.keys.factionrealm]	= factionrealmKey,
	}
end

--[[ create and return a handler object for the db, or upgrade it if it already existed ]]
local function getOptionsHandler(db, noDefaultProfiles)

	--d('local function getOptionsHandler(db, noDefaultProfiles)')

	if not defaultProfiles then
		generateDefaultProfiles(db)
	end
	
	local handler = AceDBOptions.handlers[db] or { db = db, noDefaultProfiles = noDefaultProfiles }
	
	for k,v in pairs(OptionsHandlerPrototype) do
		--d(k)
		handler[k] = v
	end
	
	AceDBOptions.handlers[db] = handler
	return handler
end

--[[
	the real options table 
]]
local optionsTable = {
	desc = {
		order = 1,
		type = "description",
		name = T["intro"] .. "\n",
	},
	descreset = {
		order = 9,
		type = "description",
		name = T["reset_desc"],
	},
	reset = {
		order = 10,
		type = "execute",
		name = T["reset"],
		desc = T["reset_sub"],
		func = "Reset",
	},
	choosedesc = {
		order = 20,
		type = "description",
		name = "\n" .. T["choose_desc"],
	},
	new = {
		name = T["new"],
		desc = T["new_sub"],
		type = "input",
		order = 30,
		get = false,
		set = "SetProfile",
	},
	choose = {
		name = T["choose"],
		desc = T["choose_sub"],
		type = "select",
		order = 40,
		get = "GetCurrentProfile",
		set = "SetProfile",
		values = "ListProfiles",
		arg = "common",
	},
	copydesc = {
		order = 50,
		type = "description",
		name = "\n" .. T["copy_desc"],
	},
	copyfrom = {
		order = 60,
		type = "select",
		name = T["copy"],
		desc = T["copy_desc"],
		get = false,
		set = "CopyProfile",
		values = "ListProfiles",
		arg = "nocurrent",
	},
	deldesc = {
		order = 70,
		type = "description",
		name = "\n" .. T["delete_desc"],
	},
	delete = {
		order = 80,
		type = "select",
		name = T["delete"],
		desc = T["delete_sub"],
		get = false,
		set = "DeleteProfile",
		values = "ListProfiles",
		arg = "nocurrent",
		confirm = true,
		confirmText = T["delete_confirm"],
	},
}

--[[
	GetOptionsTable(db)
	db - the database object to create the options table for
	
	creates and returns a option table to be used in your addon
]]
function AceDBOptions:GetOptionsTable(db, noDefaultProfiles)

	--d('AceDBOptions:GetOptionsTable(db, noDefaultProfiles)')

	local tbl = AceDBOptions.optionTables[db] or {
			type = "group",
			name = T["profiles"],
			desc = T["profiles_sub"],
		}
	
	tbl.handler = getOptionsHandler(db, noDefaultProfiles)
	tbl.args = optionsTable

	AceDBOptions.optionTables[db] = tbl
	return tbl
end

-- upgrade existing tables
for db,tbl in pairs(AceDBOptions.optionTables) do

	--d('upgrade existing tables')

	tbl.handler = getOptionsHandler(db)
	tbl.args = optionsTable
end
