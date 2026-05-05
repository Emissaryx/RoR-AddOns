
Vectors = {}
local Vectors=Vectors
local registered={}
local waiting={}
local queue={}
local data,ratio
local resolution_scale
local initstatus=0

local ANCHOR_VALUES={["x"]=true,["y"]=true,["parent"]=true,["point"]=true,["parentpoint"]=true}
local POINTS=	{
					["center"]=true,
					["top"]=true,
					["bottom"]=true,
					["left"]=true,
					["right"]=true,
					["topleft"]=true,
					["topright"]=true,
					["bottomleft"]=true,
					["bottomright"]=true
				}
local OPPOSITE_POINTS=	{
							["center"]="bottomright",
							["top"]="bottom",
							["bottom"]="top",
							["left"]="right",
							["right"]="left",
							["topleft"]="bottomright",
							["topright"]="bottomleft",
							["bottomleft"]="topright",
							["bottomright"]="topleft"
						}
local HIDE_FROM_LE=true
local SCALE_STEP=0.025
local RESOLUTIONBASE=1920
local type=type
local ipairs = ipairs
local pairs = pairs
local ti=table.insert
local tr=table.remove
local math_floor = math.floor
local string_format = string.format
local DoesWindowExist=DoesWindowExist
local WindowClearAnchors=WindowClearAnchors
local WindowAddAnchor=WindowAddAnchor
local WindowGetAnchorCount=WindowGetAnchorCount
local WindowGetAnchor=WindowGetAnchor
local WindowGetScale=WindowGetScale
local WindowSetShowing=WindowSetShowing
local InterfaceCore=InterfaceCore
local SystemData=SystemData
Vectors.LE_BEGIN=LayoutEditor.EDITING_BEGIN
Vectors.LE_END=LayoutEditor.EDITING_END
Vectors._LE_Callback_Code = nil

local WindowName, AnchorIndex, ParentWindowIndex
local FoundWindows
local ImportProfileIndex, ImportRatioIndex

function Vectors.Initialize()
	if(Vectors.data==nil)
	then
		Vectors.data=	{
							profiles		={["default"]={}},
							activeprofile	="default"
						}
		Vectors.AddProfile()
	end

	RegisterEventHandler(SystemData.Events.RESOLUTION_CHANGED,				"Vectors.ReloadData")
	RegisterEventHandler(SystemData.Events.CUSTOM_UI_SCALE_CHANGED,			"Vectors.ReloadData")
	RegisterEventHandler(SystemData.Events.LOADING_END,						"Vectors.LoadingEnd")
	RegisterEventHandler(SystemData.Events.INTERFACE_RELOADED,				"Vectors.LoadingEnd")
	CreateWindow("Vectors_Invis",false)
	WindowRegisterCoreEventHandler("Vectors_Invis","OnUpdate","Vectors.OnUpdate")

	local tmp=Vectors.data.activeprofile
	Vectors.data.activeprofile=nil
	Vectors.SwitchProfile(tmp)
	Vectors.Hook()

	if(LibSlash)then LibSlash.RegisterSlashCmd("vectors",Vectors.HandleSlash) end
end

function Vectors.LoadingEnd()
	initstatus=1
end

function Vectors.OnUpdate(e)

    if not next(queue) then
        WindowSetShowing("Vectors_Invis", false)
    else
        for i,k in pairs(queue) do
            Vectors.LoadWindow(i)
            Vectors._LE_Callback_Code = Vectors.LE_END
        end
        queue = {}
    end

    if Vectors._LE_Callback_Code ~= nil then
        if initstatus > 1.8 then
            WindowSetShowing("Vectors_Invis", false)
            local code = Vectors._LE_Callback_Code
            Vectors._LE_Callback_Code = nil
            Vectors.Call_LE_Callbacks(code)
        else
            if initstatus > 0 and e < 1 then
                initstatus = initstatus + e
            end
        end
    end
end

function Vectors.Shutdown()
	if Vectors.Settings then Vectors.Settings.Close() end
	UnregisterEventHandler(SystemData.Events.RESOLUTION_CHANGED,			"Vectors.ReloadData")
	UnregisterEventHandler(SystemData.Events.CUSTOM_UI_SCALE_CHANGED,		"Vectors.ReloadData")
	UnregisterEventHandler(SystemData.Events.LOADING_END,					"Vectors.LoadingEnd")
	UnregisterEventHandler(SystemData.Events.INTERFACE_RELOADED,			"Vectors.LoadingEnd")
	if(LibSlash)then LibSlash.UnregisterSlashCmd("vectors") end
end

function Vectors.HandleSlash(input)

    input = tostring(input or ""):lower()

    if input == "" then
        if Vectors.Settings then
            Vectors.Settings.Open()
        else
            TextLogAddEntry("Chat", 0, L"Vectors error: settings window not available.")
        end
        return
    end

    if input == "info" then
        Vectors.Info()
        return
    end

    -- Fallback help
    TextLogAddEntry("Chat", 0, L"Vectors commands:")
    TextLogAddEntry("Chat", 0, L"/vectors        open settings")
    TextLogAddEntry("Chat", 0, L"/vectors info   show debug info")
end

function Vectors.TrimRatio(ratio)
	if(type(ratio)~="number")then return end
	ratio=(math_floor(ratio*100)/100)
	return string_format("%.2f",ratio)
end

function Vectors.CalcRatio()
	return Vectors.TrimRatio(SystemData.screenResolution.x/SystemData.screenResolution.y)
end

function Vectors.CopyTable(src)
	if(type(src)~="table")
	then
		return src
	else
		local ret={}
		local i,k
		for i,k in pairs(src)
		do
			ret[i]=Vectors.CopyTable(k)
		end
		return ret
	end
end

function Vectors.UpdateCache()
	ratio=Vectors.CalcRatio()
	resolution_scale=SystemData.screenResolution.x/RESOLUTIONBASE
	local profile=Vectors.data.profiles[Vectors.data.activeprofile]
	data=profile[ratio] or {}
	profile[ratio]=data
end

function Vectors.AddProfile(name)
	if(type(name)=="wstring")then name=tostring(name) end
	if(type(name)~="string" or name:len()<1)then return false end
	if(Vectors.data.profiles[name]==nil)
	then
		local p={}
		p[Vectors.CalcRatio()]={}
		Vectors.data.profiles[name]=p
		return true
	end
	return false
end

function Vectors.DeleteProfile(name)
	if(type(name)=="wstring")then name=tostring(name) end
	if(type(name)~="string")then return false end
	if(name==Vectors.data.activeprofile)then return false end
	Vectors.data.profiles[name]=nil
	return true
end

function Vectors.GetProfiles()
	local ret={}
	for i,k in pairs(Vectors.data.profiles)
	do
		ti(ret,i)
	end
	return ret
end

function Vectors.SwitchProfile(name)
	if(type(name)=="wstring")then name=tostring(name) end
	if(type(name)~="string")then return false end
	if(not Vectors.data.profiles[name])then return false end
	if(Vectors.data.activeprofile==name)then return true end
	Vectors.data.activeprofile=name
	Vectors.ReloadData()
	return true
end

function Vectors.GetActiveProfile()
	return Vectors.data.activeprofile
end

function Vectors.ReloadData()
	Vectors.UpdateCache()
	for i,k in pairs(registered)
	do
		registered[i]=(data[i]~=nil)
	end
	Vectors.LoadProfile()
end

function Vectors.LoadProfile()
	Vectors.UpdateCache()
	waiting={}
	for i,k in pairs(data)
	do
		if(registered[i])then Vectors.LoadWindow(k) end
	end
	if Vectors.Settings then Vectors.Settings.Refresh() end
	Vectors.Set_LE_Callback_Code(Vectors.LE_END)
end

function Vectors.LoadWindow(input)
    if not input then return end

    local windowData = type(input) == "table" and input or data[input]
    local name = windowData and windowData.name or input

    if type(name) ~= "string" or registered[name] == nil or not DoesWindowExist(name) then
        return
    end

    if windowData then
        if windowData.scale then
            local scale = windowData.scale * resolution_scale
            local minscale = windowData.minscale or 0
            local dw_scale = Vectors.Dangerous_Windows[name]("scale modificator")

            if scale > minscale then
                WindowSetScale(name, scale * dw_scale)
            else
                WindowSetScale(name, minscale * dw_scale)
            end
        end

        if windowData.anchors and #windowData.anchors > 0 then
            local iscale = InterfaceCore.GetScale()
            local xf = SystemData.screenResolution.x / iscale
            local yf = SystemData.screenResolution.y / iscale

            WindowClearAnchors(name)

            for _, anchor in ipairs(windowData.anchors) do
                if DoesWindowExist(anchor.parent) then
                    WindowAddAnchor(name, anchor.parentpoint, anchor.parent, anchor.point, anchor.x * xf, anchor.y * yf)
                else
                    local list = waiting[anchor.parent]
                    if not list then
                        list = {}
                        waiting[anchor.parent] = list
                    end
                    list[name] = windowData
                end
            end
        end
    end

    local list = waiting[name]
    if list then
        waiting[name] = nil
        for _, winData in pairs(list) do
            Vectors.LoadWindow(winData)
        end
    end
end

function Vectors.ExportData(windows)
	if(type(windows)=="string")
	then
		return Vectors.CopyTable(data[windows])
	else
		if(type(windows)=="table")
		then
			local ret={}
			for i,k in ipairs(windows)
			do
				ret[k]=data[k]
			end
			return Vectors.CopyTable(ret)
		end
	end
end

function Vectors.ImportData(importData)
	if(type(importData)~="table")then return end
	for _,k in pairs(importData)
	do
		if(type(k)=="table")
		then
			local name=k.name
			data[name]=k
			if(registered[name]~=nil)
			then
				registered[name]=true
				if(HIDE_FROM_LE)then Vectors.LE_UnregisterWindow(name) end
			end
		else
			data[k]=nil
			if(registered[k]~=nil)
			then
				registered[k]=false
			end
		end
	end
end

function Vectors.MakeCopyFrom(iprofile,iratio)
	if(type(iprofile)~="string")then return end
	local profile=Vectors.data.profiles[iprofile]
	if(not profile)then return end
	local data=profile[iratio]
	if(not data)then return end
	Vectors.data.profiles[Vectors.data.activeprofile][ratio]={}
	Vectors.UpdateCache()
	Vectors.ImportData(Vectors.CopyTable(data))
	Vectors.ReloadData()
end

function Vectors.GetWindows()
	return Vectors.CopyTable(registered)
end

function Vectors.GetRatios()
	local ret={}
	for i,k in pairs(Vectors.data.profiles[Vectors.data.activeprofile])
	do
		ret[i]=i==ratio
	end
	return ret
end

function Vectors.CreateDataFromWindow(name)
	if(type(name)~="string" or not DoesWindowExist(name))then return end
	local data={["name"]=name,["anchors"]={}}
	local xres,yres=SystemData.screenResolution.x,SystemData.screenResolution.y
	local iscale=InterfaceCore.GetScale()
	local count=WindowGetAnchorCount(name)
	data.scale=WindowGetScale(name)/resolution_scale
	for i=1,count
	do
		local parentpoint,point,parent,x,y=WindowGetAnchor(name,i)
		local anchor={}
		anchor.point=point
		anchor.parent=parent
		anchor.parentpoint=parentpoint
		anchor.x=x*iscale/xres
		anchor.y=y*iscale/yres
		ti(data.anchors,anchor)
	end
	return data
end

function Vectors.AddAnchor(name)
	if(type(name)~="string" or not data[name])then return end
	local window=data[name]
	local anchors=window.anchors
	if(#anchors>=2)then return end
	local anchor={}
	if(#anchors==0)
	then
		if(WindowGetAnchorCount(name)>0)
		then
			local xres,yres=SystemData.screenResolution.x,SystemData.screenResolution.y
			local iscale=InterfaceCore.GetScale()
			local parentpoint,point,parent,x,y=WindowGetAnchor(name,1)
			anchor.point=point
			anchor.parent=parent
			anchor.parentpoint=parentpoint
			anchor.x=x*iscale/xres
			anchor.y=y*iscale/yres
		else
			anchor.point="topleft"
			anchor.parent="Root"
			anchor.parentpoint="topleft"
			anchor.x=0.5
			anchor.y=0.5
		end
	else
		local firstanchor=anchors[1]
		anchor.point=OPPOSITE_POINTS[firstanchor.point]
		local x,y=Vectors.Vis.GetCoordsFromAnchor(name,anchor.point)
		local xres,yres=SystemData.screenResolution.x,SystemData.screenResolution.y
		local iscale=InterfaceCore.GetScale()
		anchor.parent="Root"
		anchor.parentpoint="topleft"
		anchor.x=x/xres
		anchor.y=y/yres
	end
	ti(anchors,anchor)
	Vectors.LoadWindow(window)
end

function Vectors.DeleteAnchor(name,anchor)
	if(type(name)~="string" or not data[name])then return false end
	if(not data[name].anchors[anchor])then return false end
	tr(data[name].anchors,anchor)
	Vectors.LoadWindow(name)
	return true
end

function Vectors.TickValue(name,valuename,factor)
	if(type(name)~="string" or not data[name])then return end
	if(not(valuename=="scale" or valuename=="minscale"))then return end
	if(not(type(factor)=="number"))then return end
	local window=data[name]
	if(valuename=="scale" and window[valuename]==nil)then return end
	local value=(window[valuename] or 1)+SCALE_STEP*factor
	value=value>0 and value or 1
	value=value<=10 and value or 10
	window[valuename]=value
	Vectors.LoadWindow(window)
end

function Vectors.SetValue(name,valuename,value)
	if(type(name)~="string" or not data[name])then return end
	if(not(valuename=="scale" or valuename=="minscale"))then return end
	if(value~=nil and not(type(value)=="number" and value>0 and value<=10))then return end
	local window=data[name]
	window[valuename]=value
	Vectors.LoadWindow(window)
end

function Vectors.GetAnchorsCount(name)
	if(type(name)~="string")then return 0 end
	local window=data[name]
	return window and #window.anchors or 0
end

function Vectors.TickAnchorValue(name,anchor,valuename,factor)
	if(type(name)~="string" or not data[name])then return end
	if(not data[name].anchors[anchor])then return end
	if(not(valuename=="x" or valuename=="y"))then return end
	if(type(factor)~="number")then return end
	local anchor=data[name].anchors[anchor]
	local step=WindowGetScale(name)/SystemData.screenResolution[valuename]
	local value=anchor[valuename]+step*factor
	value=value>=-1 and value or -1
	value=value<=1 and value or 1
	anchor[valuename]=value
	Vectors.LoadWindow(name)
end

function Vectors.SetAnchorValue(name,anchor,valuename,value)
	if(type(name)~="string" or not data[name])then return end
	if(not data[name].anchors[anchor])then return end
	if(not ANCHOR_VALUES[valuename])then return end
	if(not(type(value)=="number" or type(value)=="string"))then return end

	if(valuename=="x" or valuename=="y")
	then
		if(value>=-1 and value<=1)
		then
			data[name].anchors[anchor][valuename]=value
		end
	elseif(valuename=="parent")
	then
		if(DoesWindowExist(value))
		then
			data[name].anchors[anchor][valuename]=value
		end
	else
		if(POINTS[value])
		then
			data[name].anchors[anchor][valuename]=value
		end
	end
	Vectors.LoadWindow(name)
end

function Vectors.Register(name)
	if(type(name)~="string")then return end
	if(not DoesWindowExist(name))then return end
	local windowdata=data[name]
	local havedata=(windowdata~=nil)
	registered[name]=havedata
	if(havedata or waiting[name])
	then
		queue[name] = name
		WindowSetShowing("Vectors_Invis",true)
	end
end

function Vectors.Unregister(name)
	if(type(name)~="string")then return end
	registered[name]=nil
end

function Vectors.LE_RW_Wrapper(windowName,...)
	Vectors.Register(windowName)
	if(not (HIDE_FROM_LE and data[windowName]))then Vectors.LE_RegisterWindow(windowName,...) end
end

function Vectors.LE_UW_Wrapper(windowName,...)
	Vectors.Unregister(windowName)
	Vectors.LE_UnregisterWindow(windowName,...)
end

function Vectors.Hook()
	Vectors.LE_RegisterWindow=LayoutEditor.RegisterWindow
	LayoutEditor.RegisterWindow=Vectors.LE_RW_Wrapper
	Vectors.LE_UnregisterWindow=LayoutEditor.UnregisterWindow
	LayoutEditor.UnregisterWindow=Vectors.LE_UW_Wrapper

	for i,k in pairs(LayoutEditor.windowsList)
	do
		Vectors.Register(i)
		if(HIDE_FROM_LE and data[i])then Vectors.LE_UnregisterWindow(i) end
	end


	LayoutEditor.Show=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data==nil)
		then
			WindowSetShowing(windowName,true)
			return
		end
		data.isAppHidden=false
		WindowSetShowing(windowName, not data.isUserHidden)
	end
	LayoutEditor.Hide=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data)
		then
			data.isAppHidden=true
		end
		WindowSetShowing(windowName,false)
	end

	LayoutEditor.IsWindowHidden=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data)
		then
			return data.isAppHidden
		else
			return WindowGetShowing(windowName)
		end
	end
	LayoutEditor.IsWindowUserHidden=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data)
		then
			return data.isUserHidden
		else
			return not WindowGetShowing(windowName)
		end
	end

	LayoutEditor.UserShow=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data==nil)
		then
			WindowSetShowing(windowName,true)
			return
		end
		data.isUserHidden=false
		WindowSetShowing(windowName, not data.isAppHidden)
	end
	LayoutEditor.UserHide=function(windowName)
		local data=LayoutEditor.windowsList[windowName]
		if(data)
		then
			data.isUserHidden=true
		end
		WindowSetShowing(windowName,false)
	end

	Frame.SetAnchor=function(self,anchor1,anchor2)
		if(not DoesWindowExist(self:GetName()))then return end
		if(anchor1)
		then
			local relativeTo	= anchor1.RelativeTo or "Root"
			if(not DoesWindowExist(relativeTo))then return end
			local point			= anchor1.Point or "topleft"
			local relativePoint = anchor1.RelativePoint or "topleft"
			local x				= anchor1.XOffset or 0
			local y				= anchor1.YOffset or 0
			WindowClearAnchors(self:GetName())
			WindowAddAnchor(self:GetName(), point, relativeTo, relativePoint, x, y)
			
			if(anchor2)
			then
				local relativeTo	= anchor2.RelativeTo or "Root"
				if(not DoesWindowExist(relativeTo))then return end
				local point			= anchor2.Point or "topleft"
				local relativePoint = anchor2.RelativePoint or "topleft"
				local x				= anchor2.XOffset or 0
				local y				= anchor2.YOffset or 0
				WindowAddAnchor(self:GetName(), point, relativeTo, relativePoint, x, y)
			end
		end
	end
end

function Vectors.Set_LE_Callback_Code(code)
	Vectors._LE_Callback_Code=code
	WindowSetShowing("Vectors_Invis",true)
end

function Vectors.Call_LE_Callbacks(code)
	for i,k in ipairs(LayoutEditor.EventHandlers)
	do
		local result,msg=pcall(k,code)
		if(not result)
		then
			LogLuaMessage("Lua",SystemData.UiLogFilters.ERROR,towstring(msg))
		end
	end
end

function Vectors.Info()
	local s="Vectors Info:\n"
	s=s.."Core-Scale: "..InterfaceCore.GetScale().."\n"
	s=s.."Res-Scale: "..SystemData.screenResolution.x/RESOLUTIONBASE.."\n"
	TextLogAddEntry("Chat",0,towstring(s))
end
