--==================
-- Data
--==================

-- 1) Addon table
MiracleGrow2 	= MiracleGrow2 or {}
local mg 		= MiracleGrow2

-- 2) Hoisted constants
local VSEED_SLICES = {
  [1]={[0]={813,200,1},[1]={529,373,.45},[2]={529,447,.45},[3]={455,447,.45},[4]={455,447,.45},[5]={948,707,1}},
  [2]={[0]={813,200,1},[1]={432,817,.45},[2]={506,817,.45},[3]={580,817,.45},[4]={580,817,.45},[5]={948,707,1}},
}
local VFRAMES = {[0]="Seed",[1]="Soil",[2]="Water",[3]="Nutrient"}

-- 3) Caches
mg._seedIcon = {}
mg._soil     = {}
mg._water    = {}
mg._nutrient = {}
mg._frameClr = {}
mg._harv     = {}

-- 4) Version etc.
mg.nVersion 	= 2.33
mg.T 			= {}
mg.sWindowName 	= "MiracleGrow2"
mg.bCIT 		= false

-- Hot upvalues (perf)
local GetCultivationInfo      		= GetCultivationInfo
local WindowGetShowing        		= WindowGetShowing
local LabelSetText            		= LabelSetText
local WindowGetDimensions     		= WindowGetDimensions
local WindowSetDimensions     		= WindowSetDimensions
local DynamicImageSetTexture  		= DynamicImageSetTexture
local DynamicImageSetTextureScale 	= DynamicImageSetTextureScale
local DynamicImageSetTextureSlice 	= DynamicImageSetTextureSlice
local WindowSetTintColor      		= WindowSetTintColor
local PlaySound               		= PlaySound
local tonumber                		= tonumber
local math_max, math_min      		= math.max, math.min
local math_floor              		= math.floor
local WindowSetShowing 				= WindowSetShowing
local WindowGetId      				= WindowGetId
local WindowGetParent  				= WindowGetParent

local str_find, str_sub 			= string.find, string.sub
local t_insert 						= table.insert

--These are the default settings
function mg.DefaultSettings()
  return {
    version=mg.nVersion,--Version of settings
    reserve=false,  --Keep a reserve?
    seedreserve=4,  --Number of seeds to maintain as a safety stock
    sound=true,     --Play sounds
    minlvl=0,       --Minimum level items to show
    maxlvl=0,       --Maximum level items to show
    showing=true,   --Show window?
    soundnum=211,   --Stage sound
    soundnum2=215,  --Completion sound
    throb=true,     --Get attention when all plots are ready
    throbc={255,0,0},
    language=0,     --Language to use
    showtoggle=false,--whether to show toggle button for the main window
    boxlayout={     --The position of all the UI elements
      [1]={3,0},
      [2]={8,0},
      [3]={13,0},
      [4]={18,0},
      [5]={25,0},
      [6]={32,0},
      [7]={32,0},
      [8]={23,1},
      [9]={31,1},
      [10]={0,1}
    },
    layout={        --General UI sizes
      dimx=39,        --plot width
      dimy=5,         --plot height
      progdimx1=24,   --progress bar corner 1
      progdimy1=0,
      progdimx2=39,   --progress bar corner 2
      progdimy2=5,
      spacing=5,      --space between plots
      arrange=1,      --plot arrangement
      count=4,        --number of plots
      border=false,   --separate plots with line
    },
    progress={
      arrange=2,      --progress bar direction
      texture=1,      --progress bar texture set
      fill={          --foreground color
        ["r"]=192,
        ["g"]=192,
        ["b"]=192,
        ["a"]=255
      },
      back={          --background color
        ["r"]=64,
        ["g"]=48,
        ["b"]=32,
        ["a"]=255
      },
    },
    boxvis={
      [1]={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true},
      [2]={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true},
      [3]={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true},
      [4]={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true},
      [8]={[0]=false,[1]=true,[2]=true,[3]=false,[4]=false},
      [9]={[0]=false,[1]=true,[2]=true,[3]=true,[4]=false},
      [10]={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true},
    },
  }
end

--This is used to keep track of when to make noise
mg.aiSoundStage={255,255,255,255}

--This is used to determine if we need to redraw
mg.aiLastState={-1,-1,-1,-1}

mg.bThrobbing=false --Getting attention?
mg.nThrobState=0

mg.nMaxTime={-1,-1,-1,-1}

--==================
-- Util functions
--==================

local function setSlice(cache, idx, wnd, stateBlack, stateSlot, stateFull)
  local cur = cache[idx]
  if cur ~= stateBlack and cur ~= stateSlot and cur ~= stateFull then cur = -1 end
  local need = stateBlack or stateSlot or stateFull
  if cur ~= need then
    DynamicImageSetTextureSlice(wnd, need)
    cache[idx] = need
  end
end

--Shorthand to output stuff in the chatbox
local function ShOut(line)
  EA_ChatWindow.Print(towstring(line))
end

--The API requires slot numbers.  We work with uniqueIDs
function mg.GetSlotByItemId(uniqueID,aExclude)
  local vBagItems=DataUtils.GetItems()
  local iSmall=10000
  local iSlot=0
  local nLoc=0
  local vItem
  for k,v in pairs(vBagItems) do
    if (v.uniqueID==uniqueID) and (v.stackCount<iSmall) then
      if (not aExclude) or (not aExclude[mg.TYPE_INVENTORY][k]) then
        iSlot=k
        iSmall=v.stackCount
        nLoc=mg.TYPE_INVENTORY
        vItem=v
      end
    end
  end
  if mg.TYPE_CRAFTING then
    vBagItems=DataUtils.GetCraftingItems()
    for k,v in pairs(vBagItems) do
      if (v.uniqueID==uniqueID) and (v.stackCount<iSmall) then
        if (not aExclude) or (not aExclude[mg.TYPE_CRAFTING][k]) then
          iSlot=k
          iSmall=v.stackCount
          nLoc=mg.TYPE_CRAFTING
          vItem=v
        end
      end
    end
  end
  return iSlot,nLoc,vItem
end

function mg.RefineItem(uniqueID,nCount)
  local nSlot,nLoc,vItem
  local aExclude={
    [mg.TYPE_INVENTORY]={},
  }
  local nLeft=nCount
  if mg.TYPE_CRAFTING then
    aExclude[mg.TYPE_CRAFTING]={}
  end
  --d("refine "..uniqueID.." "..nCount)
  while nLeft>0 do
    nSlot,nLoc,vItem=mg.GetSlotByItemId(uniqueID,aExclude)
    if nSlot~=0 then
      aExclude[nLoc][nSlot]=true
      local nGlobalLoc=mg.GetCursorForBackpack(nLoc)
      if vItem and vItem.isRefinable then
        if vItem.stackCount>nLeft then
          for i=1,nLeft do
            --d(" use "..nGlobalLoc.." "..nSlot)
            SendUseItem(nGlobalLoc,nSlot,0,0,0)
          end
          nLeft=0
        else
          nLeft=nLeft-vItem.stackCount
          for i=1,vItem.stackCount do
            --d(" use "..nGlobalLoc.." "..nSlot)
            SendUseItem(nGlobalLoc,nSlot,0,0,0)
          end
        end
      end
    else
      return
    end
  end
end

---------------------------
-- Init stuff
---------------------------
function mg.Initialize()
  if not mg.vSettings then
    mg.vSettings=mg.DefaultSettings()
  else
    mg.UpdateSettings()
  end

  if EA_Window_Backpack.POCKET_MAIN_INVENTORY_INDEX then
    mg.TYPE_INVENTORY=EA_Window_Backpack.POCKET_MAIN_INVENTORY_INDEX
  else
    mg.TYPE_INVENTORY=EA_Window_Backpack.TYPE_INVENTORY
  end
  mg.TYPE_CRAFTING=EA_Window_Backpack.TYPE_CRAFTING
  
  mg.SetLanguage(mg.vSettings.language)
    
  -- Load LibSlash and register commands	
	mg.LoadAddon("LibSlash")
	if LibSlash then
	  LibSlash.RegisterSlashCmd("mg",mg.DoCommand)
	  LibSlash.RegisterSlashCmd("mgremix",mg.DoCommand)
	  LibSlash.RegisterSlashCmd("MiracleGrow2",mg.DoCommand)
	end
	
	mg.LoadAddon("Crafting Info Tooltip")
	if CraftValueTip and CraftValueTip.version and (CraftValueTip.version>=1.23) then
	  mg.bCIT=true
	end
	
	LayoutEditor.RegisterWindow(mg.sWindowName,mg.GetPhrase("general","mgremix"),mg.GetPhrase("general","mgremixdesc"), false, false, true, nil)

  WindowSetShowing(mg.sWindowName.."Icon",mg.vSettings.showtoggle)
  if mg.vSettings.showtoggle then
	  LayoutEditor.RegisterWindow(mg.sWindowName.."Icon",L"MGRemix",mg.GetPhrase("tooltips","togglewindow"), false, false, true, nil)
	end

	--Make sure we update if the stage changes
  WindowRegisterEventHandler(mg.sWindowName,SystemData.Events.PLAYER_CULTIVATION_UPDATED,"MiracleGrow2.onCultUpdate");
  --Explicitly load the cultivation data on zone-in
	RegisterEventHandler(SystemData.Events.LOADING_END,"MiracleGrow2.onZone")
	--Make sure we update if there's new inventory
	RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED,"MiracleGrow2.onInvChange")
  if mg.TYPE_CRAFTING then
	  RegisterEventHandler(SystemData.Events.PLAYER_CRAFTING_SLOT_UPDATED,"MiracleGrow2.onInvChange")
	end

  mg.HRInit()

  mg.InitConfig()
  
  mg.LayoutMainWindow()
end

function mg.LoadAddon(sModName)
	local _modules=ModulesGetData()
	for k,v in ipairs(_modules) do
		if v.name == sModName then
			if v.isEnabled and not v.isLoaded then
				ModuleInitialize(v.name)
			end
			return
		end
	end
end

function mg.UpdateSettings()
  local vDefaults=mg.DefaultSettings()
  local vClassic  = mg.DefaultClassic and mg.DefaultClassic() or vDefaults
  --Force the complaint when the version changes and optional dependancies are missing
  if mg.vSettings.version~=mg.nVersion then
    mg.vSettings.bRunOnce=false
  end
  
  --Convert 2.14 to 2.15
  if not mg.vSettings.version then
    mg.vSettings.seedreserve=vDefaults.seedreserve
    mg.vSettings.version=2.15
  end
  --Convert 2.15 to 2.16
  if mg.vSettings.version<2.16 then
    mg.vSettings.language=0
    mg.vSettings.version=2.16
  end
  
  --Convert 2.16 to 2.18
  if mg.vSettings.version<2.18 then
    if mg.vSettings.seedreserve and (mg.vSettings.seedreserve>0) then
      mg.vSettings.reserve=true
    else
      mg.vSettings.reserve=false
      mg.vSettings.seedreserve=4
    end
    if not mg.vSettings.minlvl or (mg.vSettings.minlvl==1) then
      mg.vSettings.minlvl=0
    end
    mg.vSettings.throbc={255,0,0}
    mg.vSettings.version=2.18
  end
  
  --Convert 2.18 to 2.19
  if mg.vSettings.version<2.19 then
    mg.vSettings.showtoggle=false
    mg.vSettings.version=2.19
  end
  
  --Convert 2.19 to 2.20
  --  If we're upgrading, we use classic layout instead of default
  if mg.vSettings.version<2.20 then
    mg.vSettings.boxlayout=vClassic.boxlayout
    mg.vSettings.layout=vClassic.layout
    mg.vSettings.progress=vClassic.progress
    mg.vSettings.boxvis=vClassic.boxvis
    mg.vSettings.version=2.20
  end
  
  mg.vSettings.version=mg.nVersion
  if not mg.VerifySettings() then
    ShOut(L"MiracleGrow Remix has that its settings are corrupt. All settings have been reset to default.")
    mg.vSettings=mg.DefaultSettings()
  end
end

local function Check(vVar, sType, nMin, nMax)
  if vVar == nil or type(vVar) ~= sType then return false end
  if nMin and vVar < nMin then return false end
  if nMax and vVar > nMax then return false end
  return true
end

function mg.VerifySettings()
  local vS = mg.vSettings
  if not (Check(vS.version,"number",2,3)
     and Check(vS.reserve,"boolean")
     and Check(vS.seedreserve,"number",0)
     and Check(vS.sound,"boolean")
     and Check(vS.minlvl,"number",0,200)
     and Check(vS.maxlvl,"number",0,200)
     and Check(vS.showing,"boolean")
     and Check(vS.soundnum,"number")
     and Check(vS.soundnum2,"number")
     and Check(vS.throb,"boolean")
     and Check(vS.throbc,"table")
     and Check(vS.language,"number",0)
     and Check(vS.showtoggle,"boolean")
     and Check(vS.boxlayout,"table")
     and Check(vS.layout,"table")
     and Check(vS.progress,"table")
     and Check(vS.boxvis,"table")) then
    return false
  end

  -- throbc table present above; now its fields
  if not (Check(vS.throbc[1],"number",0,255)
     and  Check(vS.throbc[2],"number",0,255)
     and  Check(vS.throbc[3],"number",0,255)) then
    return false
  end

  -- layout fields
  if not (Check(vS.layout.dimx,"number",0,50)
     and  Check(vS.layout.dimy,"number",0,50)
     and  Check(vS.layout.progdimx1,"number",0,50)
     and  Check(vS.layout.progdimy1,"number",0,50)
     and  Check(vS.layout.progdimx2,"number",0,50)
     and  Check(vS.layout.progdimy2,"number",0,50)
     and  Check(vS.layout.spacing,"number",0,1000)
     and  Check(vS.layout.arrange,"number",1,3)
     and  Check(vS.layout.count,"number",1,4)
     and  Check(vS.layout.border,"boolean")) then
    return false
  end

  -- progress main: guard vTexCombo
  local texMax = (type(mg.vTexCombo)=="table" and #mg.vTexCombo>0) and #mg.vTexCombo or 999
  if not (Check(vS.progress.arrange,"number",1,5)
     and  Check(vS.progress.texture,"number",0,texMax)
     and  Check(vS.progress.fill,"table")
     and  Check(vS.progress.back,"table")) then
    return false
  end

  -- progress tints
  if not (Check(vS.progress.fill.r,"number",0,255)
     and  Check(vS.progress.fill.g,"number",0,255)
     and  Check(vS.progress.fill.b,"number",0,255)
     and  Check(vS.progress.fill.a,"number",0,255)
     and  Check(vS.progress.back.r,"number",0,255)
     and  Check(vS.progress.back.g,"number",0,255)
     and  Check(vS.progress.back.b,"number",0,255)
     and  Check(vS.progress.back.a,"number",0,255)) then
    return false
  end

  return true
end

function mg.SetLanguage(nLang)
  --0 means use default
  if nLang==0 then
    nLang=SystemData.Settings.Language.active
  end

  --First try specified language
  if mg.T[nLang] then
    mg.nLanguage=nLang
    mg.vLocal=mg.T[mg.nLanguage]
    mg.HRSetLang()
    return true
  --Second try game language
  elseif mg.T[SystemData.Settings.Language.active] then
    mg.nLanguage=SystemData.Settings.Language.active
    mg.vLocal=mg.T[mg.nLanguage]
    mg.HRSetLang()
    return false
  --Fall back to English
  else
    mg.nLanguage=1
    mg.vLocal=mg.T[mg.nLanguage]
    mg.HRSetLang()
    return false
  end
end

function mg.GetPhrase(sType,sPhraseName,sSlot1,sSlot2,sSlot3,sSlot4)
  if (not mg.vLocal[sType]) or (not mg.vLocal[sType][sPhraseName]) then
    d("MGRemix: Unknown phrase: "..sType.."."..sPhraseName)
    return L""
  end
  local sResult=mg.vLocal[sType][sPhraseName]
  if sSlot1 then
    sResult=wstring.gsub(sResult,L"{1}",towstring(sSlot1))
  end
  if sSlot2 then
    sResult=wstring.gsub(sResult,L"{2}",towstring(sSlot2))
  end
  if sSlot3 then
    sResult=wstring.gsub(sResult,L"{3}",towstring(sSlot3))
  end
  if sSlot4 then
    sResult=wstring.gsub(sResult,L"{4}",towstring(sSlot4))
  end
  
  return sResult
end

---------------------------
-- Script Commands
---------------------------
function mg.show()
	WindowSetShowing(mg.sWindowName, true);
	mg.vSettings.showing=true;
  mg.ForceUpdate()
end

function mg.hide()
  WindowSetShowing(mg.sWindowName, false);
	mg.vSettings.showing=false;
end

function mg.toggle()
  if mg.vSettings.showing then
    mg.hide()
  else
    mg.show()
  end
end

function mg.reserve(nCount)
  if nCount ~= nil then
    if nCount>0 then
      mg.vSettings.reserve=true
      mg.vSettings.seedreserve=nCount;
      ShOut(mg.GetPhrase("messages","reserve",nCount))
    else
      mg.vSettings.reserve=false
      ShOut(mg.GetPhrase("messages","reserveoff"))
    end  
  end  
end

---------------------------
-- Dependancy notification
---------------------------
function mg.onMouseOver()
  if mg.vSettings.bRunOnce then
    return
  end
  mg.Complain()
  mg.vSettings.bRunOnce=true
end

function mg.Complain()
  local bComplain=false
  local bCIT=false
  local sComplaint=L""
  if not LibSlash then
    sComplaint=sComplaint..L"\n\n"..mg.GetPhrase("rant","libsnoinstall")..L"  "..mg.GetPhrase("rant","libs1")
    bComplain=true
  end
  if not CraftValueTip then
    sComplaint=sComplaint..L"\n\n"..mg.GetPhrase("rant","citnoinstall")..L"  "
    bCIT=true
    bComplain=true
  elseif (not CraftValueTip.version) or (CraftValueTip.version<1.23) then
    sComplaint=sComplaint..L"\n\n"..mg.GetPhrase("rant","citupdate")..L"  "..mg.GetPhrase("rant","version",1.23)..L"  "
    bCIT=true
    bComplain=true
  end
  if bCIT then
    sComplaint=sComplaint..mg.GetPhrase("rant","cit1")
  end
  if bComplain then
--    d(sComplaint)
    sComplaint=mg.GetPhrase("rant","rantprefix")..sComplaint..L"\n\n"..mg.GetPhrase("rant","rantpostfix")
    DialogManager.MakeOneButtonDialog(sComplaint,GetString(StringTables.Default.LABEL_OKAY))
  end
end

--------------------------
-- Command Stuff
--------------------------

function mg.DoCommand(input)
  local args=mg.explode(" ",input);
  if args[1] == "hide" then
    mg.hide()
  elseif args[1] == "show" then
    mg.show()
  elseif args[1] == "sound" then
    if args[2] == "on" then
      mg.vSettings.sound=true;
      ShOut(mg.GetPhrase("messages","soundon"))
    else
      mg.vSettings.sound=false;
      ShOut(mg.GetPhrase("messages","soundoff"))
    end
  elseif args[1] == "throb" then
    if args[2] == "on" then
      mg.vSettings.throb=true;
      ShOut(mg.GetPhrase("messages","throbon"))
    else
      mg.vSettings.throb=false;
      ShOut(mg.GetPhrase("messages","throboff"))
    end
  elseif args[1] == "minlvl" then
    local tmp = tonumber(args[2])
    if tmp ~=nil and tmp <= 200 and tmp >=0 then
      mg.vSettings.minlvl=tmp;
      ShOut(mg.GetPhrase("messages","minlvl",tmp))
    else
      ShOut(mg.GetPhrase("messages","minlvlerr"))
    end 
  elseif args[1] == "maxlvl" then
    local tmp = tonumber(args[2])
    if tmp ~=nil and tmp <= 200 and tmp > 0 then
      mg.vSettings.maxlvl=tmp;
      ShOut(mg.GetPhrase("messages","maxlvl",tmp))
    else
      if tmp ~=nil and tmp == 0 then
        mg.vSettings.maxlvl=tmp;
        ShOut(mg.GetPhrase("messages","maxlvldef"))
      else
        ShOut(mg.GetPhrase("messages","maxlvlerr"))
      end
    end 
  elseif args[1] == "soundnum" then
    local tmp = tonumber(args[2])
    if tmp ~= nil then
      mg.vSettings.soundnum=tmp
    end  
  elseif args[1] == "soundnum2" then
    local tmp = tonumber(args[2])
    if tmp ~= nil then
      mg.vSettings.soundnum2=tmp
    end  
  elseif args[1] == "playsound" then
    local tmp = tonumber(args[2])
    if tmp ~= nil then
      PlaySound(tmp);
    end  
  elseif args[1] == "reserve" then
    local tmp = tonumber(args[2])
    if tmp ~= nil then
      if tmp>0 then
        mg.vSettings.reserve=true
        mg.vSettings.seedreserve=tmp
        ShOut(mg.GetPhrase("messages","reserve",tmp))
      else
        mg.vSettings.reserve=false
        ShOut(mg.GetPhrase("messages","reserveoff"))
      end  
    end
  elseif args[1]=="" then
    IraConfig.Open(mg.nConfigTab)
  else
    ShOut(mg.GetPhrase("messages","help1",mg.nVersion))
    ShOut(mg.GetPhrase("messages","help2"))
    ShOut(mg.GetPhrase("messages","help0"))
    ShOut(mg.GetPhrase("messages","help3"))
    ShOut(mg.GetPhrase("messages","help4"))
    ShOut(mg.GetPhrase("messages","help5"))
    ShOut(mg.GetPhrase("messages","help6"))
    ShOut(mg.GetPhrase("messages","help7"))
    ShOut(mg.GetPhrase("messages","help8"))
    ShOut(mg.GetPhrase("messages","help9"))
    ShOut(mg.GetPhrase("messages","help10"))
    ShOut(mg.GetPhrase("messages","help11"))
    ShOut(mg.GetPhrase("messages","help12"))
    if mg.bCIT then
      ShOut(mg.GetPhrase("messages","help13"))
    end
  end  
end


function mg.explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  for st,sp in function() return str_find(str,div,pos,true) end do
    t_insert(arr,str_sub(str,pos,st-1)) 
    pos = sp + 1
  end
  t_insert(arr,str_sub(str,pos))
  return arr
end

--------------------------
-- Tooltips
--------------------------
function mg.onHoverSeed()
	local name = SystemData.MouseOverWindow.name
  local id = WindowGetId(WindowGetParent(name))
  local plotData=GetCultivationInfo(id)
  if plotData.Seed.uniqueID~=0 then
    Tooltips.CreateItemTooltip(plotData.Seed,name,Tooltips.ANCHOR_WINDOW_VARIABLE)
  else
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name,mg.GetPhrase("tooltips","addseed"))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
	end
end

function mg.onHoverSoil()
	local name = SystemData.MouseOverWindow.name
  local id = WindowGetId(WindowGetParent(name))
  local plotData=GetCultivationInfo(id)
  if plotData.Additives[2].uniqueID~=0 then
    Tooltips.CreateItemTooltip(plotData.Additives[2],name,Tooltips.ANCHOR_WINDOW_VARIABLE)
  else
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name,mg.GetPhrase("tooltips","addsoil"))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
	end
end

function mg.onHoverWater()
	local name = SystemData.MouseOverWindow.name
  local id = WindowGetId(WindowGetParent(name))
  local plotData=GetCultivationInfo(id)
  if plotData.Additives[3].uniqueID~=0 then
    Tooltips.CreateItemTooltip(plotData.Additives[3],name,Tooltips.ANCHOR_WINDOW_VARIABLE)
  else
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name,mg.GetPhrase("tooltips","addwater"))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
	end
end

function mg.onHoverNutrient()
	local name = SystemData.MouseOverWindow.name
  local id = WindowGetId(WindowGetParent(name))
  local plotData=GetCultivationInfo(id)
  if plotData.Additives[4].uniqueID~=0 then
    Tooltips.CreateItemTooltip(plotData.Additives[4],name,Tooltips.ANCHOR_WINDOW_VARIABLE)
  else
    Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name,mg.GetPhrase("tooltips","addnut"))
    Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
	end
end

--------------------------
-- Events
--------------------------
-- throttle knobs
mg._uiTick    = 0.10   -- update plots/UI at 10 Hz
mg._throbTick = 0.20   -- throb tint at 5 Hz
mg._acc       = 0
mg._throbAcc  = 0
mg._lastTint  = -1

function mg.OnUpdate(dt)
  -- game logic can stay per-frame
  mg.HRUpdate(dt)

  -- cache showing once
  local showing = WindowGetShowing(mg.sWindowName)

  -- UI work at 10 Hz
  mg._acc = mg._acc + dt
  if mg._acc >= mg._uiTick then
    mg._acc = mg._acc - mg._uiTick
    for i=1,4 do mg.UpdatePlot(i) end
    if mg.LayoutUpdate then mg.LayoutUpdate(mg._uiTick) end
  end
  if not showing or not mg.vSettings.throb then return end

  -- compute idle/ready once
  local bAllIdle, bHarvestReady = true, false
  for i=1,4 do
    local s = mg.aiSoundStage[i]
    if s == 4 then bHarvestReady = true
    elseif s ~= 0 and s ~= 5 then bAllIdle = false end
  end

  if not (bAllIdle and bHarvestReady) then
    if mg.bThrobbing then
      mg.bThrobbing = false
      WindowSetTintColor(mg.sWindowName.."BackgroundBackground", 0, 0, 0)
      mg._lastTint = -1
    end
    return
  end

  -- throb at 5 Hz and only write if color changed
  mg._throbAcc = mg._throbAcc + dt
  if mg._throbAcc < mg._throbTick then return end
  mg._throbAcc = mg._throbAcc - mg._throbTick

  mg.bThrobbing = true
  mg.nThrobState = (mg.nThrobState + mg._throbTick) % 3
  local t = mg.nThrobState
  local nColor = (t > 1.5) and ((3 - t) / 1.5) or (t / 1.5)

  local r = math_floor(mg.vSettings.throbc[1] * nColor + 0.5)
  local g = math_floor(mg.vSettings.throbc[2] * nColor + 0.5)
  local b = math_floor(mg.vSettings.throbc[3] * nColor + 0.5)
  local key = r * 65536 + g * 256 + b

  if key ~= mg._lastTint then
    WindowSetTintColor(mg.sWindowName.."BackgroundBackground", r, g, b)
    mg._lastTint = key
  end
end

--Set the window visibility, force cultivation information availablity
function mg.onZone()
--  d("Zone")
	if GameData.TradeSkillLevels[GameData.TradeSkills.CULTIVATION] == 0 then
		WindowSetShowing(mg.sWindowName, false);
	else
	  if mg.vSettings.showing then
  		WindowSetShowing(mg.sWindowName, true);
    else
  		WindowSetShowing(mg.sWindowName, false);
  	end
		CultivationWindow.InitAllPlots()  --This forces the cultivation data to load
    mg.ForceUpdate()
	end
end

--If we are explicity told the cultivation state has changed, be sure we reflect the change
function mg.onCultUpdate(culslot)
  mg.ForceUpdate()
	mg.UpdatePlot(culslot)
end

--Whether we can repeat is dependant on our inventory, so...
function mg.onInvChange(updatedSlots)
  mg.ForceUpdate()
end


------------------------
-- Update stuff
------------------------

--Make noise if it's time
local function Noise(iPlot,iStage)
  if mg.aiSoundStage[iPlot]==255 then
    mg.aiSoundStage[iPlot]=iStage;
    return
  end
  if mg.aiSoundStage[iPlot]~=iStage then
    mg.aiSoundStage[iPlot]=iStage;
    if mg.vSettings.sound then
      if (iStage==2) or (iStage==3) then
        PlaySound(mg.vSettings.soundnum);
      elseif (iStage==4) then
        PlaySound(mg.vSettings.soundnum2);
      end
    end  
  end
end

--Force a full update for all plots
function mg.ForceUpdate()
  for i=1,4 do
    mg.aiLastState[i]=-1
  end
end

-- Update a plot (optimized, with uniqueID safety)
function mg.UpdatePlot(i)
  local vPlot = GetCultivationInfo(i)
  if not vPlot then return end

  local sBaseName = mg.sWindowName.."Plant"..i
  local seed = vPlot.Seed or {}
  local adds = vPlot.Additives or {}
  adds[2] = adds[2] or { uniqueID = 0 }
  adds[3] = adds[3] or { uniqueID = 0 }
  adds[4] = adds[4] or { uniqueID = 0 }

  local iStageNum = vPlot.StageNum or 0
  local nType = (seed.cultivationType == 5) and 2 or 1

  -- lazy init small caches
  mg._lastTime  = mg._lastTime  or { -1,-1,-1,-1 }
  mg._lastStage = mg._lastStage or { -1,-1,-1,-1 }
  mg._lastBar   = mg._lastBar   or { [1]={-1,-1}, [2]={-1,-1}, [3]={-1,-1}, [4]={-1,-1} }

  -- clamp stage 0..5 (5 = sentinel for >4)
  if iStageNum > 4 then iStageNum = 5 end

  -- timers and progress
  if iStageNum == 0 then
    mg.nMaxTime[i] = -1
  elseif iStageNum <= 3 then
    if mg.nMaxTime[i] == -1 then
      mg.nMaxTime[i] = vPlot.TotalTimer
    end
    if WindowGetShowing(mg.sWindowName) then
      local tTot = tonumber(vPlot.TotalTimer) or 0
      local tStg = tonumber(vPlot.StageTimer) or 0
      if mg._lastTime[i] ~= tTot then
        LabelSetText(sBaseName.."Time",  towstring(tTot)..L"s")
        mg._lastTime[i] = tTot
      end
      if mg._lastStage[i] ~= tStg then
        LabelSetText(sBaseName.."Stage", towstring(tStg)..L"s")
        mg._lastStage[i] = tStg
      end
      if mg.vSettings.progress.arrange > 1 and mg.nMaxTime[i] and mg.nMaxTime[i] > 0 then
        local bx, by = WindowGetDimensions(sBaseName.."Bar")
        local ratio = math_max(0, math_min(1, tTot / mg.nMaxTime[i]))
        local nx, ny = bx - (bx * ratio), by - (by * ratio)
        local lx, ly = mg._lastBar[i][1], mg._lastBar[i][2]
        if nx ~= lx or ny ~= ly then
          WindowSetDimensions(sBaseName.."BarFill", nx, ny)
          mg._lastBar[i][1], mg._lastBar[i][2] = nx, ny
        end
      end
    end
  end

  -- heavy UI only when state changes
  local iState = iStageNum
  if adds[2].uniqueID ~= 0 then iState = iState + 16 end
  if adds[3].uniqueID ~= 0 then iState = iState + 32 end
  if adds[4].uniqueID ~= 0 then iState = iState + 64 end
  if iState == mg.aiLastState[i] then return end
  mg.aiLastState[i] = iState

  if mg.PrioritizePlots then mg.PrioritizePlots() end
  if mg.HRUpdatePlot then mg.HRUpdatePlot(i, vPlot) end

  if not WindowGetShowing(mg.sWindowName) then return end

  Noise(i, iStageNum)
  mg.SetVisibility(i, iStageNum)

  -- Seed icon
  do
    mg._seedIcon = mg._seedIcon or {}
    local key = nType*10 + iStageNum
    if mg._seedIcon[i] ~= key then
      local s = VSEED_SLICES[nType][iStageNum]
      if s then
        DynamicImageSetTexture(sBaseName.."ButtonSeedIcon", "EA_Cultivating01_d5", s[1], s[2])
        DynamicImageSetTextureScale(sBaseName.."ButtonSeedIcon", s[3])
      end
      mg._seedIcon[i] = key
    end
  end

  -- Soil/Water/Nutrient icons
  mg._soil, mg._water, mg._nutrient = mg._soil or {}, mg._water or {}, mg._nutrient or {}
  if iStageNum == 5 then
    setSlice(mg._soil,     i, sBaseName.."ButtonSoilIcon",     "Black-Slot")
    setSlice(mg._water,    i, sBaseName.."ButtonWaterIcon",    "Black-Slot")
    setSlice(mg._nutrient, i, sBaseName.."ButtonNutrientIcon", "Black-Slot")
  else
    setSlice(mg._soil,     i, sBaseName.."ButtonSoilIcon",
      nil, (adds[2].uniqueID==0) and "Dirt-Slot" or nil,     (adds[2].uniqueID~=0) and "Dirt" or nil)
    setSlice(mg._water,    i, sBaseName.."ButtonWaterIcon",
      nil, (adds[3].uniqueID==0) and "WaterDrop-Slot" or nil,(adds[3].uniqueID~=0) and "WaterDrop" or nil)
    setSlice(mg._nutrient, i, sBaseName.."ButtonNutrientIcon",
      nil, (adds[4].uniqueID==0) and "GreenCross-Slot" or nil,(adds[4].uniqueID~=0) and "GreenCross" or nil)
  end

  -- Frame tint
  mg._frameClr = mg._frameClr or {}
  for k, name in pairs(VFRAMES) do
    local wantGreen = (iStageNum == k) and 1 or 0
    local fkey = i*10 + k
    if mg._frameClr[fkey] ~= wantGreen then
      local frame = sBaseName.."Button"..name
      local col = wantGreen==1 and DefaultColor.GREEN or DefaultColor.RED
      WindowSetTintColor(frame, col.r, col.g, col.b)
      WindowSetTintColor(frame.."Icon", DefaultColor.ZERO_TINT.r, DefaultColor.ZERO_TINT.g, DefaultColor.ZERO_TINT.b)
      mg._frameClr[fkey] = wantGreen
    end
  end

  -- Harvest icons
  mg._harv = mg._harv or {}
  if mg._harv[i] ~= nType then
    if nType == 2 then
      DynamicImageSetTexture(sBaseName.."HarvestIcon",       "EA_Cultivating01_d5", 761, 512)
      DynamicImageSetTexture(sBaseName.."HarvestRepeatIcon", "EA_Cultivating01_d5", 761, 512)
    else
      DynamicImageSetTexture(sBaseName.."HarvestIcon",       "EA_Cultivating01_d5", 829,   0)
      DynamicImageSetTexture(sBaseName.."HarvestRepeatIcon", "EA_Cultivating01_d5", 829,   0)
    end
    DynamicImageSetTextureScale(sBaseName.."HarvestIcon", .125)
    mg._harv[i] = nType
  end
end

function mg.ToggleClick()
  mg.toggle()
end

function mg.ToggleRClick()
  IraConfig.Open(mg.nConfigTab)
end

function mg.ToggleHover()
	WindowSetAlpha(mg.sWindowName.."IconLight",.1)
  Tooltips.CreateTextOnlyTooltip(SystemData.ActiveWindow.name,mg.GetPhrase("tooltips","togglewindow"))
  Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_VARIABLE)
end

function mg.ToggleNoHover()
	WindowSetAlpha(mg.sWindowName.."IconLight",0)
end

function mg.SetVisibility(nPlot,nStageNum)
if type(mg.vBoxData) ~= "table" then return end
  for k,v in ipairs(mg.vBoxData) do
    --Only control windows that we control...
    if mg.vSettings.boxvis[k] then
      --If we control it, should it be visible?
      if mg.vSettings.boxlayout[k] and (mg.vSettings.boxvis[k][nStageNum] or (nStageNum>4)) then
        WindowSetShowing(mg.sWindowName.."Plant"..nPlot..v.win,true)
      else
        WindowSetShowing(mg.sWindowName.."Plant"..nPlot..v.win,false)
      end
    end
  end
  if (nStageNum>0) and (nStageNum<4) then
    WindowSetShowing(mg.sWindowName.."Plant"..nPlot.."Bar",true)
  else
    WindowSetShowing(mg.sWindowName.."Plant"..nPlot.."Bar",false)
  end
end

function mg.AddCraftingItem(nSkill,nData,nSlot,nBag)
  if mg.TYPE_CRAFTING then
    AddCraftingItem(nSkill,nData,nSlot,nBag)
  else
    AddCraftingItem(nSkill,nData,nSlot)
  end
end

function mg.GetCursorForBackpack(nBackpackType)
  if EA_Window_Backpack.GetCursorForBackpack then
    return EA_Window_Backpack.GetCursorForBackpack(nBackpackType)
  else
    return GameData.ItemLocs.INVENTORY
  end
end
