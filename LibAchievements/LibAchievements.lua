-- Warhammer Online LibAchievements

-- Icona / Tempest (icona@gmx.net)
-- Feel free to e-mail me regarding new ideas, changes, bugs, comments, etc.

-- this file's contents are released under Creative Commons Attribution-Noncommercial-Share Alike 3.0
-- http://creativecommons.org/licenses/by-nc-sa/3.0/

-- la namespace
if not LibAchievements then
  LibAchievements = {}
  LibAchievements.Categories = {}
  LibAchievements.Pages = {}
end

local fnTomeGetAchievementsTOC
local fnTomeGetAchievementsSubTypeData
local fnTomeSetAchievementsSubTypeImage
local fnOpenBraggingRightsContextMenu

local start_id = -1
local next_id = start_id

function LibAchievements.Initialize()
  -- hook function calls
  fnTomeGetAchievementsTOC = TomeGetAchievementsTOC
  TomeGetAchievementsTOC = LibAchievements.TomeGetAchievementsTOC
  
  fnTomeGetAchievementsSubTypeData = TomeGetAchievementsSubTypeData
  TomeGetAchievementsSubTypeData = LibAchievements.TomeGetAchievementsSubTypeData
  
  fnTomeSetAchievementsSubTypeImage = TomeSetAchievementsSubTypeImage
  TomeSetAchievementsSubTypeImage = LibAchievements.TomeSetAchievementsSubTypeImage
  
  fnOpenBraggingRightsContextMenu = TomeWindow.OpenBraggingRightsContextMenu
  TomeWindow.OpenBraggingRightsContextMenu = LibAchievements.OpenBraggingRightsContextMenu
  
  -- destroy existing tome windows/controls (mythic's tome code won't fix anchors etc. when updating)
  for i = 1, TomeWindow.Achievements.typeTOCWindowCount do
    DestroyWindow("AchievementsTypeTOCItem"..i)
  end
  for i = 1, TomeWindow.Achievements.subTypeTOCWindowCount do
    DestroyWindow("AchievementsSubTypeTOCItem"..i)
  end
  TomeWindow.Achievements.typeTOCWindowCount = 0
  TomeWindow.Achievements.subTypeTOCWindowCount = 0
end

function LibAchievements.OpenBraggingRightsContextMenu(id)
  if id == nil or id > -1 then
    fnOpenBraggingRightsContextMenu(id)
  end
end

function LibAchievements.TomeSetAchievementsSubTypeImage(id)
  if id > -1 then
    fnTomeSetAchievementsSubTypeImage(id)
  end
end

function LibAchievements.TomeGetAchievementsTOC()
  local ret = fnTomeGetAchievementsTOC()
  
  for i,v in pairs(LibAchievements.Categories) do
    local n = #ret + 1
	ret[n] = {}
    ret[n].id = n
	ret[n].name = v.name
	ret[n].subtypes = {}

	for j,w in pairs(v.pages) do
      ret[n].subtypes[j] = {}
      ret[n].subtypes[j].id = w.id
      --ret[n].subtypes[j].numUnlocks = 0
	  local c = 0
	  for k,x in pairs(LibAchievements.Pages[w.id].entries) do
	    if x.func() then c = c + 1 end
	  end
	  ret[n].subtypes[j].numUnlocks = c
      ret[n].subtypes[j].name = w.name
      ret[n].subtypes[j].isUnlocked = w.unlocked and w.id ~= 0
	end
  end
  return ret
end

function LibAchievements.TomeGetAchievementsSubTypeData(id)
  if id > -1 then
    return fnTomeGetAchievementsSubTypeData(id)
  else
    -- update unlock status
    for i,v in pairs(LibAchievements.Pages[id].entries) do
	  LibAchievements.Pages[id].entries[i].isUnlocked = LibAchievements.Pages[id].entries[i].func()
	end
    return LibAchievements.Pages[id]
  end
end

function LibAchievements.CreateCategory(name)
  local i = 1
  if type(name) == "string" then name = towstring(name) end

  for i,v in pairs(LibAchievements.Categories) do
    if v.name == name then return i end
  end
    
  while LibAchievements.Categories[i] ~= nil do
    i = i + 1
  end
  
  LibAchievements.Categories[i] = {}
  LibAchievements.Categories[i].name = name
  LibAchievements.Categories[i].pages = {}
  
  return i
end

function LibAchievements.AppendEntry(pageid,name,desc,func)
  local i = #LibAchievements.Pages[pageid].entries + 1  
 
  --LibAchievements.Pages[pageid].entries[i] = {}
  LibAchievements.UpdateEntry(pageid,i,name,desc,func)
  return i
end

function LibAchievements.UpdateEntry(pageid,entryid,name,desc,func)
  local i = entryid
  LibAchievements.Pages[pageid].entries[i] = {}
  LibAchievements.Pages[pageid].entries[i].name = name
  LibAchievements.Pages[pageid].entries[i].id = -1
  LibAchievements.Pages[pageid].entries[i].func = func
  LibAchievements.Pages[pageid].entries[i].isUnlocked = func()
  LibAchievements.Pages[pageid].entries[i].desc = desc
  LibAchievements.Pages[pageid].entries[i].rewards = {}
  return i
end

function LibAchievements.CreatePage(catid,name,unlocked,desc)
  local i = 1
  if type(name) == "string" then name = towstring(name) end
  
  for i,v in pairs(LibAchievements.Categories[catid].pages) do
    if v.name == name then return i end
  end
  
  while LibAchievements.Categories[catid].pages[i] ~= nil do
    i = i + 1
  end
  
  LibAchievements.Categories[catid].pages[i] = {}
  LibAchievements.Categories[catid].pages[i].name = name
  LibAchievements.Categories[catid].pages[i].id = next_id
  LibAchievements.Categories[catid].pages[i].unlocked = unlocked
  
  LibAchievements.Pages[next_id] = {}
  LibAchievements.Pages[next_id].id = next_id
  LibAchievements.Pages[next_id].name = name
  LibAchievements.Pages[next_id].desc = desc
  LibAchievements.Pages[next_id].entries = {}
  
  next_id = next_id - 1
  return next_id + 1
end
