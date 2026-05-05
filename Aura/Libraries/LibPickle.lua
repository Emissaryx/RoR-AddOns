--------------------------------------------------------------------------------
-- Copyright (c) 2009 Bloodwalker <metagamegeek@gmail.com>
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--------------------------------------------------------------------------------
-- Thanks to ckknight (ckknight@gmail.com) and his LibJSON for many chunks of
-- code that were the template for several of the unpickling methods
--------------------------------------------------------------------------------
-- File:      LibPickle.lua
-- Date:      2009-01-31T09:30:33Z
-- Author:    Bloodwalker <metagamegeek@gmail.com>
-- Version:   beta-0.2.2
-- Revision:  13
-- File Rev:  13
-- Copyright: 2009
--------------------------------------------------------------------------------

local MAJOR,MINOR = "LibPickle-0.2", 2
local LibPickle, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not LibPickle then return end -- no upgrade needed

--------------------------------------------------------------------------------
-- Local Var Declarations
--------------------------------------------------------------------------------
local reverseSolidus = ("\\"):byte()
local openBrace = ("{"):byte()
local closeBrace = ("}"):byte()
local openBracket = ("["):byte()
local closeBracket = ("]"):byte()
local comma = (","):byte()
local colon = (":"):byte()
local semicolon = (";"):byte()
local doubleQuote = ('"'):byte()
local singleQuote = ("'"):byte()
local minus = ("-"):byte()
local plus = ("+"):byte()
local letterT = ("t"):byte()
local letterF = ("f"):byte()
local fullStop = ("."):byte()
local letterE = ("e"):byte()
local letterUpperE = ("E"):byte()
local numbers = {}
for i = 0, 9 do
	numbers[i + ('0'):byte()] = i
end

local function wgsub(s, pattern, replace)
	-- fix for wstring, returns an empty string instead of empty wstring
	local clean, number = wstring.gsub(s, pattern, replace)
	if clean == "" then
		clean = L""
	end
	return clean
end

--------------------------------------------------------------------------------
-- Local Serializing functions (Pickling)
--------------------------------------------------------------------------------
local Pickler = {
	clone = function (t)
				local nt={}
				for i, v in pairs(t) do
					nt[i]=v
				end
				return nt
			end 
}

function Pickler:pickle(root)
	if type(root) ~= "table" then 
		error("Can only pickle tables, not ".. type(root).."s")
	end
	self.tableToRef = {}
	self.refToTable = {}
	local savecount = 0
	self:ref(root)
	local s = L""

	while table.getn(self.refToTable) > savecount do
		savecount = savecount + 1
		local t = self.refToTable[savecount]
		if savecount > 1 then
			s = s .. L","
		end
		s = s .. L"{"
		local membercount = 0
		for i, v in pairs(t) do
			membercount = membercount + 1
			if membercount > 1 then
				s = s .. L","
			end
			s = s .. L"" .. self:value(i) .. L":" .. self:value(v)
		end
		s = s .. L"}"
	end

	return L"{" .. s .. L"}P1"
end

function Pickler:value(v)
	local vtype = type(v)
	if     vtype == "string" then return L"'" .. self:escapes(v) .. L"'" --wstring.format(L"%q", towstring(v))
	elseif vtype == "wstring" then return L'"' .. self:escapew(v) .. L'"' -- quoteing string doesnt work properly for wstrings
	elseif vtype == "number" then return towstring(v)
	elseif vtype == "boolean" then
		if v then return L"t"
		else return L"f"
		end
	elseif vtype == "table" then return L"[" .. self:ref(v) .. L"]" -- table reference indicator
	elseif vtype == "function" then return L'"' .. towstring(tostring(v)) .. L'"'
	else error("LibPickle a "..type(v).." is not supported")
	end  
end

function Pickler:ref(t)
	local ref = self.tableToRef[t]
	if not ref then 
		if t == self then error("Can't pickle the LibPickle class") end
			table.insert(self.refToTable, t)
			ref = table.getn(self.refToTable)
			self.tableToRef[t] = ref
		end
	return ref
end

function Pickler:escapes(s)
	return self:escapew(towstring(s))
end

function Pickler:escapew(s)
	local clean = wgsub(s, L"\\", L"\\\\")
	clean = wgsub(clean, L"'", L"\\'")
	clean = wgsub(clean, L'"', L'\\"')
	clean = wgsub(clean, L'\b', L'\\b')
	clean = wgsub(clean, L'\f', L'\\f')
	clean = wgsub(clean, L'\n', L'\\n')
	clean = wgsub(clean, L'\r', L'\\r')
	clean = wgsub(clean, L'\t', L'\\t')
	return clean
end

--------------------------------------------------------------------------------
-- Local Deserializing functions (Unpickling)
--------------------------------------------------------------------------------
local DePickler = {
	clone = function (t)
				local nt={}
				for i, v in pairs(t) do
					nt[i]=v
				end
				return nt
			end 
}
DePickler.debugPickle = false
DePickler.level = 0

function DePickler:unescapes(s)
	return self:escapew(towstring(s))
end

function DePickler:unescapew(s)
	local clean = wgsub(s, L"\\\\", L"\\")
	clean = wgsub(clean, L"\\'", L"'")
	clean = wgsub(clean, L'\\"', L'"')
	clean = wgsub(clean, L'\\b', L'\b')
	clean = wgsub(clean, L'\\f', L'\f')
	clean = wgsub(clean, L'\\n', L'\n')
	clean = wgsub(clean, L'\\r', L'\r')
	clean = wgsub(clean, L'\\t', L'\t')
	return clean
end

function DePickler:getReference(s, position)
	if self.debugPickle then self:dPrint(s, position, "getReference") end
	position = position + 1
	local ref, position = self:scan(s, position)
    local charbyte = s:byte(position)
    position = position + 1
	if charbyte == closeBracket then
		self.level = self.level - 1
		return "[" .. ref .. "]", position
	else
		error("Incomplete reference tag")
	end
	
end

function DePickler:getBoolean(s, position)
	if self.debugPickle then self:dPrint(s, position, "getBoolean") end
	local bool = s:sub(position, position):byte()
	
	self.level = self.level - 1
	if bool == letterT then
		return true, position + 1
	elseif bool == letterF then
		return false, position + 1
	else
		error("Improper boolean")
	end
end

function DePickler:getNumber(s, position)
	if self.debugPickle then self:dPrint(s, position, "getNumber") end
	local start = position
	local charbyte = s:byte(position)
	position = position + 1

	if charbyte == minus then
		charbyte = s:byte(position)
		position = position + 1
	end

	local number = numbers[charbyte]
	if not number then
		error("Number ended early: " .. tostring(s))
	end

	if number ~= 0 then
		while true do
			charbyte = s:byte(position)
			position = position + 1
			local digit = numbers[charbyte]
			if not digit then
				break
			end
		end
	else
		charbyte = s:byte(position)
		position = position + 1
	end

	if charbyte == fullStop then
		local first = true
		local exponent = 0
		while true do
			charbyte = s:byte(position)
			position = position + 1

			if not numbers[charbyte] then
				if first then
					error(("Number ended early: %q"):format(s))
				end
				break
			end
			first = false
		end
	end
	
	if charbyte == letterE or charbyte == letterUpperE then
		charbyte = s:byte(position)
		position = position + 1

		if charbyte == plus or charbyte == minus then
			-- nothing to do
		else
			position = position - 1
		end

		charbyte = s:byte(position)
		position = position + 1

		if not numbers[charbyte] then
			error(("Invalid number: %q"):format(s))
		end

		repeat
			charbyte = s:byte(position)
			position = position + 1
		until not numbers[charbyte]
	end
	position = position - 1
	-- we're gonna use number because it's typically faster and more accurate than adding and multiplying ourselves
	local number = tonumber(s:sub(start, position-1))
	assert(number)
	self.level = self.level - 1
	return number, position
end

function DePickler:getString(s, position)
	if self.debugPickle then self:dPrint(s, position, "getString") end
	assert(s:byte(position) == singleQuote)
	position = position + 1
	local start = position
	
	while true do
		local charbyte = s:byte(position)
		position = position + 1
		if not charbyte then
			error(("String ended early: %q"):format(s))
		elseif charbyte == singleQuote then
			break -- end of string
		elseif charbyte == reverseSolidus then
			charbyte = s:byte(position)
			position = position + 1
		end
	end
	
	if start == position - 1 then
		chunk = ""
	else
		chunk = WStringToString(self:unescapew(s:sub(start, position - 2)))
	end
	self.level = self.level - 1
	return chunk, position
end

function DePickler:getWString(s, position)
	if self.debugPickle then self:dPrint(s, position, "getWString") end
	assert(s:byte(position) == doubleQuote)
	position = position + 1
	local start = position
	
	while true do
		local charbyte = s:byte(position)
		position = position + 1
		if not charbyte then
			error(("WString ended early: %q"):format(s))
		elseif charbyte == doubleQuote then
			break -- end of string
		elseif charbyte == reverseSolidus then
			charbyte = s:byte(position)
			position = position + 1
		end
	end

	if start == position - 1 then
		chunk = L""
	else
		chunk = self:unescapew(s:sub(start, position - 2))
	end
	
	if self.debugPickle then d(towstring(string.rep("  ", self.level) ).. L"Chunk = " .. chunk) end
	self.level = self.level - 1
	return chunk, position
end

function DePickler:getTable(s, position)
	if self.debugPickle then self:dPrint(s, position, "getTable") end
	assert(s:byte(position) == openBrace)
	position = position + 1
	
	if s:byte(position) == closeBrace then
		return {}, position + 1
	end
	local result = {}
	
	local skip = false
	while true do
		local key
		key, position = self:scan(s, position)

		local charbyte = s:byte(position)
		position = position + 1
		
		if not charbyte then
			error("Invalid dictionary: " .. tostring(s) .. ", ended early")
		elseif charbyte == comma then
			table.insert(result, key)
			skip = true
		elseif charbyte == closeBrace then
			table.insert(result, key)
			position = position + 1
			self.level = self.level - 1
			return result, position
		elseif charbyte ~= colon then
			error("Invalid table ending because of " .. tostring(s:sub(position - 1 )) ..  " at position " .. tostring(position - 1))
		end

		if not skip then 
			local val
			val, position = self:scan(s, position)
			result[key] = val
			
			local charbyte = s:byte(position)
			position = position + 1
			
			if charbyte == closeBrace then
				self.level = self.level - 1
				return result, position
			elseif not charbyte then
				error("Invalid dictionary: " .. tostring(s) .. ", ended early")
			elseif charbyte ~= comma then
				error("Invalid table ending because of " .. tostring(s:sub(position - 1 )) ..  " at position " .. tostring(position - 1))
			end
		end
	end
	
end
	
function DePickler:scan(s, position)
	if self.debugPickle then self:dPrint(s, position, "Scanning ") end
	local nextByte = s:byte(position)
	
	if not nextByte then
		error("Premature end of string at position " .. tostring(position - 1) )
	end
	self.level = self.level - 1
	if nextByte == openBracket then	return self:getReference(s, position)
	elseif nextByte == openBrace then return self:getTable(s, position)
	elseif nextByte == singleQuote then return self:getString(s, position)
	elseif nextByte == doubleQuote then	return self:getWString(s, position)
	elseif nextByte == minus or numbers[nextByte] then return self:getNumber(s, position)
	elseif nextByte == letterT or nextByte == letterF then return self:getBoolean(s, position)
	else
		error("Invalid input: " .. tostring( s:sub(position, position) ) .. " at position " .. tostring(position))
	end
	
end

function DePickler:unpickle(s)
	if type(s) ~= "wstring" then
		error("Can't unpickle a "..type(s)..", only wstrings")
	end
	local pickleString = wstring.match(s, L"P1$")
	if not pickleString then
		error("Invalid input: This is wstring was not pickled by LibPickle")
	end
	s = wstring.gsub(s, L"P1$", L"")
	
	local unpickled, position = self:scan(s, 1)
	
	local function restoreReference( luaTable )
		for k, i in pairs(luaTable) do
			if type(i) == "table" then
				restoreReference(i)
			elseif type(i) == "string" then
				local ref = i:match("^%[(%d+)%]$")
				if ref then
					luaTable[k] = unpickled[tonumber(ref)]
				end
			end
			if type(k) == "table" then
				restoreReference(k)
			elseif type(k) == "string" then
				local ref = k:match("^%[(%d+)%]$")
				if ref then
					luaTable[unpickled[tonumber(ref)]] = i
					luaTable[k] = nil
				end
			end
		end
		return luaTable
	end

	for k, t in pairs(unpickled) do
		restoreReference(t)
	end
	
	return unpickled[1]
end

function DePickler:dPrint(s, position, func)
	self.level = self.level + 1
	d(string.rep("  ", self.level) .. tostring(func))
	d(string.rep("  ", self.level) .. "Found " .. tostring(s:sub(position, position)) )
end

--------------------------------------------------------------------------------
-- Global Functions
--------------------------------------------------------------------------------
function LibPickle.pickle(t)
	local success, result = pcall( Pickler.pickle, Pickler:clone(), t )
	if not success then return nil end
	return result
end

function LibPickle.unpickle(s)
	local success, result = pcall( DePickler.unpickle, DePickler:clone(), s )
	if not success then return nil end
	return result
end

function Pickle(t)
	local success, result = pcall( Pickler.pickle, Pickler:clone(), t )
	if not success then return nil end
	return result
end

function Unpickle(s)
	local success, result = pcall( DePickler.unpickle, DePickler:clone(), s )
	if not success then return nil end
	return result
end

--------------------------------------------------------------------------------
-- Self Test Functions
--------------------------------------------------------------------------------
local bool = true
local inputT = {}
inputT[1] = "Numeric Key"
inputT["1"] = "String Numeric Key"
inputT.stringKey = "Simple String Key"
inputT[L"1"] = "WString Numeric Key"
inputT[L"wstring Key"] = "Second String Value"
inputT[{}] = "Table Key"
inputT[bool] = "Boolean Key"
inputT["circular"] = inputT
inputT["WString Value"] = L"WString goes here"
inputT["Boolean Value"] = true
inputT["Table Value"] = {}


function LibPickle.selftest( sampleTable )
	if not sampleTable then
		sampleTable = inputT
	end
	local pickled = Pickle(sampleTable)
	local unpickled = Unpickle(pickled)

	for k, v in pairs(sampleTable) do
		if type(k) == "table" or type(v) == "table" then
			if k == "circular" and v ~= sampleTable then -- test for circular reference
				error(MAJOR .. " self-test failed! on circular reference check" )
			elseif type(k) == "table" and v ~= "Table Key" then
				error(MAJOR .. " self-test failed! on using tables as keys" )
			end
			-- skip this since it wont be the same table anyways
		elseif not unpickled[k] or v ~= unpickled[k] then
			d("***Input:***")
			d(sampleTable)
			d("***Output:***")
			d(unpickled)
			error(MAJOR .. " self-test failed! on " .. tostring(k) )
		end
	end
	d(MAJOR .. " self-test table output ")
	d(unpickled)
	d(MAJOR .. " self-test PASSED!")
end

--d(MAJOR .. " Loaded")
