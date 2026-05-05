
local Settings={}
Vectors.Settings=Settings
local working,originalscale
local WindowIndex,ProfileIndex,AnchorIndex
local WindowData,WindowDataBackup
local SettingsWindow = "Vectors_Settings_ScrollWindow_ScrollChild_"

local pairs = pairs
local ipairs = ipairs
local string = string
local tostring = tostring
local ti = table.insert

local string_find = string.find
local string_sub = string.sub
local string_len = string.len

local I2POINTS=	{
					"center",
					"top",
					"bottom",
					"left",
					"right",
					"topleft",
					"topright",
					"bottomleft",
					"bottomright"
				}
local POINTS2I
local RATIOS=	{
					[Vectors.TrimRatio(3/2)]=L"3:2",
					[Vectors.TrimRatio(4/3)]=L"4:3",
					[Vectors.TrimRatio(5/3)]=L"5:3",
					[Vectors.TrimRatio(5/4)]=L"5:4",
					[Vectors.TrimRatio(15/9)]=L"15:9",
					[Vectors.TrimRatio(16/9)]=L"16:9",
					[Vectors.TrimRatio(16/10)]=L"16:10",
					[Vectors.TrimRatio(25/16)]=L"25:16"
				}
local STEP=		{
					["S"]=0.2,
					["N"]=1,
					["F"]=10,
					["NS"]=-0.2,
					["NN"]=-1,
					["NF"]=-10
				}
local DIRECTION={
					["FW"]="x",
					["BW"]="x",
					["UW"]="y",
					["DW"]="y"
				}

local function reversetable(t)
	local ret={}
	for i,k in pairs(t)
	do
		ret[k]=i
	end
	return ret
end

POINTS2I=reversetable(I2POINTS)

local function float2text(value)
	return wstring.format(L"%0.7f",value)
end

function Settings.Create()
	CreateWindow("Vectors_Settings",false)
	Settings.WindowHiderInit(SettingsWindow.."Profile")
	Settings.WindowHiderInit(SettingsWindow.."Anchor")
	Settings.SetLabels()
	Settings.FillComboboxes()
	WindowSetHandleInput("Vectors_Settings",false)
	WindowSetShowing("Vectors_Settings",false)
	Fader.Register("Vectors_Settings",0.75)
	LayoutEditor.RegisterEditCallback(Settings.LE_Callback)
end

function Settings.Open()
	working=true
	Settings.PopulateProfiles()
	if(not WindowGetHandleInput("Vectors_Settings"))
	then
		WindowSetHandleInput("Vectors_Settings",true)
		Fader.FadeTo("Vectors_Settings",1)
	end
	Vectors.Set_LE_Callback_Code(Vectors.LE_BEGIN)
	working=false
end

function Settings.Close()
	working=true
	Settings.DisableShowMinScale()
	if(WindowGetHandleInput("Vectors_Settings"))
	then
		WindowSetHandleInput("Vectors_Settings",false)
		Fader.FadeTo("Vectors_Settings",0)
	end
	Vectors.Set_LE_Callback_Code(Vectors.LE_END)
	Vectors.Vis.Shutdown()
	working=false
end

function Settings.Refresh()
	working=true
	if(DoesWindowExist("Vectors_Settings") and WindowGetAlpha("Vectors_Settings")>0)
	then
		Settings.PopulateProfiles()
	end
	working=false
end

function Settings.LE_Callback(code)
	if(code==Vectors.LE_END and (WindowGetHandleInput("Vectors_Settings") or LayoutEditor.isActive or (DoesWindowExist("Vectors_Import") and WindowGetAlpha("Vectors_Import")>0)))
	then
		Vectors.Set_LE_Callback_Code(Vectors.LE_BEGIN)
	end
end

function Settings.SetLabels()
	LabelSetText("Vectors_SettingsTitleBarText",L"Vectors")
	local list=		{
						["Profile_Content_Profile"]			= L"Profiles",
						["Window"]							= L"Windows",
						["WindowPoint"]						= L"Point on Window",
						["ReferenceWindow"]					= L"Reference",
						["ReferenceWindowPoint"]			= L"Point on Reference",
						["Cross"]							= L"X and Y Offset",
						["Scale"]							= L"Scale",
						["LockScale"]						= L"Lock Scale",
						["MinScale"]						= L"Minimum Scale",
						["ShowMinScale"]					= L"Show Minimum"
					}
	for i,k in pairs(list)
	do
		LabelSetText(SettingsWindow..i.."Text",k)
	end

		list=		{
						["Profile_Content_AddProfile"]		= L"Add",
						["Profile_Content_DeleteProfile"]	= L"Delete",
						["Profile_Content_OpenImport"]		= L"Open Import Window",
						["SwitchData"]						= L"Create Dataset",
						["ReadoutData"]						= L"Read Data from UI",
						["ResetWindow"]						= L"Reset Window",
						["Anchor_Content_AddAnchor"]		= L"Add",
						["Anchor_Content_DeleteAnchor"]		= L"Delete"
					}
	for i,k in pairs(list)
	do
		ButtonSetText(SettingsWindow..i,k)
	end
end

function Settings.FillComboboxes()
	local box

	box=SettingsWindow.."WindowPointComboBox"
	ComboBoxClearMenuItems(box)
	for i,k in ipairs(I2POINTS)
	do
		ComboBoxAddMenuItem(box,towstring(k))
	end

	box=SettingsWindow.."ReferenceWindowPointComboBox"
	ComboBoxClearMenuItems(box)
	for i,k in ipairs(I2POINTS)
	do
		ComboBoxAddMenuItem(box,towstring(k))
	end
end

function Settings.ButtonClicked()
	local button=SystemData.ActiveWindow.name
	if(ButtonGetDisabledFlag(button))then return end
	if(working)then return
	else working=true end
	local _,_,name=string_find(button,"[_,%w]+_(%w+)")
	if(Settings[name])then Settings[name]() end
	working=false
end

function Settings.ComboBoxChanged()
	local box=SystemData.ActiveWindow.name
	if(ComboBoxGetDisabledFlag(box))then return end
	if(working)then return
	else working=true end
	local idx=ComboBoxGetSelectedMenuItem(box)
	local _,_,name=string_find(box,"[_,%w]+_(%w+)ComboBox")
	if(Settings[name.."Changed"])then Settings[name.."Changed"](idx) end
	working=false
end

function Settings.CheckBoxToggled()
	local checkbox=SystemData.ActiveWindow.name
	local button=checkbox.."Button"
	if(ButtonGetDisabledFlag(button))then return end
	if(working)then return
	else working=true end
	local pressed=not ButtonGetPressedFlag(button)
	ButtonSetPressedFlag(button,pressed)
	local _,_,name=string_find(checkbox,"[_,%w]+_(%w+)CheckBox")
	if(Settings[name.."Toggled"])then Settings[name.."Toggled"](pressed) end
	working=false
end

function Settings.WindowHiderInit(name)
	Settings.WindowHiderShow(name,false)
end

function Settings.WindowHiderOpenClicked()
	Settings.WindowHiderShowClicked(false)
end

function Settings.WindowHiderClosedClicked()
	Settings.WindowHiderShowClicked(true)
end

function Settings.WindowHiderShowClicked(show)
	local _,_,name=string_find(SystemData.ActiveWindow.name,"([_,%w]+)Button%w+")
	Settings.WindowHiderShow(name,show)
end

function Settings.WindowHiderShow(name,show)
	WindowSetShowing(name.."ButtonOpen",show)
	WindowSetShowing(name.."ButtonClosed",not show)
	WindowSetShowing(name.."_Content",show)
	WindowClearAnchors(name.."End")
	WindowAddAnchor(name.."End","bottomleft",show and name.."_Content" or name,"bottomleft",0,5)
	ScrollWindowUpdateScrollRect("Vectors_Settings_ScrollWindow")
end

function Settings.ArrowClicked()
	if(working)then return
	else working=true end
	local arrow=SystemData.ActiveWindow.name
	local _,_,name,step,direction=string_find(arrow,"[_,%w]+_(%w+)_(%w+)_(%w+)")
	if(Settings[name.."Clicked"])then Settings[name.."Clicked"](STEP[step],DIRECTION[direction]) end
	working=false
end

function Settings.FloatEditBoxChanged()
	local editbox=SystemData.ActiveWindow.name
	local text=TextEditBoxGetText(editbox)
	if(text==L"")then return end
	if(working)then return
	else working=true end
	local _,_,name,direction=string_find(editbox,"[_,%w]+_(%w+)_(%w+)_FloatEditBox")
	local value=tonumber(text)
	local newvalue=value<=-10 and -10 or value
	newvalue=newvalue>=10 and 10 or newvalue
	local newtext=towstring(towstring(towstring(text:gsub(L"[^%d|\.|-]",L"")):gsub(L"^-",L"_")):gsub(L"-",L"")):gsub(L"_",L"-")
	if(newtext~=text)then TextEditBoxSetText(editbox,towstring(newtext)) end
	if(newvalue~=value)then TextEditBoxSetText(editbox,float2text(newvalue)) end
	if(Settings[name.."Changed"])then Settings[name.."Changed"](newvalue,direction:lower()) end
	working=false
end

function Settings.UpdateFromSource()
	WindowData=Vectors.ExportData(WindowName)
	Vectors.Vis.Show(WindowName,AnchorIndex)
end

function Settings.PopulateProfiles()
	local box=SettingsWindow.."Profile_Content_ProfileComboBox"
	local active=Vectors.GetActiveProfile()
	local hit=0
	ComboBoxClearMenuItems(box)
	ProfileIndex={}
	for i,k in pairs(Vectors.GetProfiles())
	do
		ComboBoxAddMenuItem(box,towstring(k))
		ti(ProfileIndex,k)
		if(k==active)then hit=#ProfileIndex end
	end
	ComboBoxSetSelectedMenuItem(box,hit)

	LabelSetText(SettingsWindow.."ProfileText1",L"Profile \""..towstring(active)..L"\" currently loaded ("..#ProfileIndex..L" available)")

	local s=L""
	for i,k in pairs(Vectors.GetRatios())
	do
		s=s..L" "..(RATIOS[i] or towstring(i))
		if(k)
		then
			s=s..L"*"
		end
	end
	LabelSetText(SettingsWindow.."ProfileText2",L"aspect ratio:"..s)

	WindowName=nil
	Settings.PopulateWindowList()
end

function Settings.PopulateWindowList()
	local box=SettingsWindow.."WindowComboBox"
	ComboBoxClearMenuItems(box)
	WindowIndex={}
	local NewSelection
	local list=Vectors.GetWindows()
	for i,k in pairs(list)
	do
		ti(WindowIndex,i)
	end
	table.sort(WindowIndex)
	for i,k in ipairs(WindowIndex)
	do
		if(WindowName==k)then NewSelection=i end
		ComboBoxAddMenuItem(box,towstring(list[k] and L"true " or L"false")..L" - "..towstring(k:sub(0,25)))
	end
	if(NewSelection)then ComboBoxSetSelectedMenuItem(box,NewSelection) end
	Settings.WindowChanged(NewSelection)
end

function Settings.PopulateWindow()
	Settings.PopulateAnchors()
	Settings.PopulateScale()
	Settings.PopulateMinScale()
	if(WindowName==nil)
	then
		ButtonSetDisabledFlag(SettingsWindow.."SwitchData",true)
	else
		ButtonSetDisabledFlag(SettingsWindow.."SwitchData",false)
		if(WindowData)
		then
			ButtonSetText(SettingsWindow.."SwitchData",L"Delete Dataset")
		else
			ButtonSetText(SettingsWindow.."SwitchData",L"Create Dataset")
		end
	end

	local flag=WindowName==nil or not WindowData
	ButtonSetDisabledFlag(SettingsWindow.."ReadoutData",flag)
	ButtonSetDisabledFlag(SettingsWindow.."ResetWindow",flag)
	ComboBoxSetDisabledFlag(SettingsWindow.."WindowPointComboBox",flag)
	ComboBoxSetDisabledFlag(SettingsWindow.."ReferenceWindowComboBox",flag)
	ComboBoxSetDisabledFlag(SettingsWindow.."ReferenceWindowPointComboBox",flag)
end

function Settings.PopulateAnchors()
	local box=SettingsWindow.."Anchor_Content_AnchorsComboBox"
	ComboBoxClearMenuItems(box)
	local count=Vectors.GetAnchorsCount(WindowName)
	for i=1,count
	do
		ComboBoxAddMenuItem(box,towstring(i)..L": "..towstring(WindowData.anchors[i].point)..L" -> "..towstring(WindowData.anchors[i].parentpoint)..L"@"..towstring(WindowData.anchors[i].parent))
	end
	ComboBoxSetSelectedMenuItem(box,AnchorIndex)

	if(AnchorIndex>0)
	then
		LabelSetText(SettingsWindow.."AnchorText1",L"Anchor #"..towstring(AnchorIndex)..L" currently highlighted")
	else
		LabelSetText(SettingsWindow.."AnchorText1",L"no Anchors currently loaded")
	end

	Settings.PopulateWindowPoint()
	Settings.PopulateReferenceWindow()
	Settings.PopulateReferenceWindowPoint()
	Settings.PopulateCross()
end

function Settings.PopulateWindowPoint()
	local box=SettingsWindow.."WindowPointComboBox"
	ComboBoxSetSelectedMenuItem(box,WindowData and WindowData.anchors[AnchorIndex] and POINTS2I[WindowData.anchors[AnchorIndex].point] or 0)
end

function Settings.PopulateReferenceWindow()
	local box=SettingsWindow.."ReferenceWindowComboBox"
	ComboBoxClearMenuItems(box)
	ParentWindowIndex={}
	if(WindowData and WindowData.anchors[AnchorIndex])
	then
		local NewSelection
		local parent=WindowData.anchors[AnchorIndex].parent
		local list=Vectors.GetWindows()
		list[WindowName]=nil
		for i,k in pairs(list)
		do
			ti(ParentWindowIndex,i)
		end
		table.sort(ParentWindowIndex)
		ti(ParentWindowIndex,1,"Root")
		for i,k in ipairs(ParentWindowIndex)
		do
			if(parent==k)then NewSelection=i end
			ComboBoxAddMenuItem(box,towstring(k:sub(0,26)))
		end
		ComboBoxSetSelectedMenuItem(box,NewSelection)
	end
end

function Settings.PopulateReferenceWindowPoint()
	local box=SettingsWindow.."ReferenceWindowPointComboBox"
	ComboBoxSetSelectedMenuItem(box,WindowData and WindowData.anchors[AnchorIndex] and POINTS2I[WindowData.anchors[AnchorIndex].parentpoint] or 0)
end

function Settings.PopulateCross()
	local editbox_X=SettingsWindow.."Cross_X_FloatEditBox"
	local editbox_Y=SettingsWindow.."Cross_Y_FloatEditBox"
	TextEditBoxSetText(editbox_X,WindowData and WindowData.anchors[AnchorIndex] and float2text(WindowData.anchors[AnchorIndex].x) or L"")
	TextEditBoxSetText(editbox_Y,WindowData and WindowData.anchors[AnchorIndex] and float2text(WindowData.anchors[AnchorIndex].y) or L"")
end

function Settings.PopulateScale()
	local editbox=SettingsWindow.."Scale_X_FloatEditBox"
	TextEditBoxSetText(editbox,WindowData and WindowData.scale and float2text(WindowData.scale) or L"")
	local button=SettingsWindow.."LockScaleCheckBoxButton"
	ButtonSetPressedFlag(button,WindowData and WindowData.scale~=nil or false)
end

function Settings.PopulateMinScale()
	local editbox=SettingsWindow.."MinScale_X_FloatEditBox"
	TextEditBoxSetText(editbox,WindowData and float2text(WindowData.minscale or 0) or L"")
	local button=SettingsWindow.."ShowMinScaleCheckBoxButton"
	ButtonSetPressedFlag(button,originalscale~=nil)
end

function Settings.ProfileChanged(idx)
	Vectors.SwitchProfile(ProfileIndex[idx])
	Settings.PopulateWindowList()
end

function Settings.WindowChanged(idx)
	if(idx==0)then return end
	Settings.DisableShowMinScale()
	local oldName=WindowName
	WindowName=WindowIndex[idx]
	WindowData=Vectors.ExportData(WindowName)
	if(oldName~=WindowName)
	then
		WindowDataBackup=Vectors.CopyTable(WindowData or Vectors.CreateDataFromWindow(WindowName))
		Settings.AnchorsChanged(1)
	else
		Settings.AnchorsChanged(AnchorIndex or 1)
	end
	Settings.PopulateWindow()
end

function Settings.AnchorsChanged(idx)
	local maxanchors=Vectors.GetAnchorsCount(WindowName)
	local exist=WindowName and DoesWindowExist(WindowName)
	idx=idx>=0 and idx or 0
	idx=idx<=maxanchors and idx or maxanchors
	AnchorIndex=idx
	ButtonSetDisabledFlag(SettingsWindow.."Anchor_Content_AddAnchor",not(exist and maxanchors<2))
	ButtonSetDisabledFlag(SettingsWindow.."Anchor_Content_DeleteAnchor",not(exist and maxanchors>0))
	Settings.UpdateFromSource()
	Settings.PopulateAnchors()
end

function Settings.WindowPointChanged(idx)
	Vectors.SetAnchorValue(WindowName,AnchorIndex,"point",I2POINTS[idx])
	Settings.UpdateFromSource()
	Settings.PopulateAnchors()
end

function Settings.ReferenceWindowChanged(idx)
	Vectors.SetAnchorValue(WindowName,AnchorIndex,"parent",ParentWindowIndex[idx])
	Settings.UpdateFromSource()
	Settings.PopulateAnchors()
end

function Settings.ReferenceWindowPointChanged(idx)
	Vectors.SetAnchorValue(WindowName,AnchorIndex,"parentpoint",I2POINTS[idx])
	Settings.UpdateFromSource()
	Settings.PopulateAnchors()
end

function Settings.AddProfile()
	DialogManager.MakeTextEntryDialog(L"New Profile",L"Enter new Profile Name",L"New Profile",Settings.AddProfile_2nd,nil,20)
end

function Settings.AddProfile_2nd(name)
	local profiles=Vectors.GetProfiles()
	if(name==nil or name==L"")then return end
	name=tostring(name)
	for i,k in ipairs(profiles)
	do
		if(k==name)
		then
			DialogManager.MakeOneButtonDialog(L"Profilename already exists",L"OK")
			return
		end
	end
	Vectors.AddProfile(name)
	Settings.PopulateProfiles()
end

function Settings.DeleteProfile()
	local box=SettingsWindow.."Profile_Content_ProfileComboBox"
	local idx=ComboBoxGetSelectedMenuItem(box)
	local profiles=Vectors.GetProfiles()
	if(#profiles<=1)
	then
		DialogManager.MakeOneButtonDialog(L"This is your last Profile, you can't delete it",L"OK")
		return
	end
	Vectors.SwitchProfile(ProfileIndex[idx-1] or ProfileIndex[idx+1])
	Vectors.DeleteProfile(ProfileIndex[idx])
	Settings.PopulateProfiles()
end

function Settings.SwitchData()
	Settings.DisableShowMinScale()
	if(WindowData)
	then
		Vectors.ImportData({WindowData.name})
		WindowData=nil
	else
		WindowData=Vectors.CreateDataFromWindow(WindowName)
		Vectors.ImportData({WindowData})
		AnchorIndex=Vectors.GetAnchorsCount(WindowName)>0 and 1 or 0
		Vectors.LoadWindow(WindowName)
	end
	Settings.PopulateWindowList()
end

function Settings.ReadoutData()
	Settings.DisableShowMinScale()
	local oldData=WindowData
	WindowData=Vectors.CreateDataFromWindow(WindowName)
	WindowData.minscale=oldData.minscale
	Vectors.ImportData({WindowData})
	Settings.AnchorsChanged(1)
	Vectors.LoadWindow(WindowName)
	Settings.PopulateWindow()
end

function Settings.ResetWindow()
	Settings.DisableShowMinScale()
	Vectors.ImportData({WindowDataBackup})
	Settings.AnchorsChanged(1)
	WindowData=Vectors.ExportData(WindowName)
	WindowDataBackup=Vectors.CopyTable(WindowData)
	Vectors.LoadWindow(WindowName)
	Settings.UpdateFromSource()
	Settings.PopulateWindow()
end

function Settings.AddAnchor()
	Vectors.AddAnchor(WindowName)
	Settings.AnchorsChanged(Vectors.GetAnchorsCount(WindowName))
end

function Settings.DeleteAnchor()
	Vectors.DeleteAnchor(WindowName,AnchorIndex)
	Settings.AnchorsChanged(AnchorIndex)
end

function Settings.ShowMinScaleToggled(active)
	if(active)
	then
		if(WindowData)
		then
			originalscale=WindowData.scale
			Vectors.SetValue(WindowName,"scale",WindowData.minscale or 0.00001/InterfaceCore.GetScale())
			Settings.UpdateFromSource()
		end
		Settings.PopulateMinScale()
	else
		Settings.DisableShowMinScale()
	end
end

function Settings.LockScaleToggled(active)
	if(not WindowName)then return end
	if(active)
	then
		local data=Vectors.CreateDataFromWindow(WindowName)
		Vectors.SetValue(WindowName,"scale",data.scale)
		Settings.UpdateFromSource()
	else
		Settings.ScaleChanged(nil)
	end
	Settings.PopulateScale()
end

function Settings.DisableShowMinScale()
	local button=SettingsWindow.."ShowMinScaleCheckBoxButton"
	ButtonSetPressedFlag(button,false)
	if(originalscale and WindowName)
	then
		Vectors.SetValue(WindowName,"scale",originalscale)
		Settings.UpdateFromSource()
		originalscale=nil
	end
	Settings.PopulateMinScale()
end

function Settings.CrossClicked(step,direction)
	if(not WindowName)then return end
	Vectors.TickAnchorValue(WindowName,AnchorIndex,direction,step)
	Settings.UpdateFromSource()
	Settings.PopulateCross()
end

function Settings.CrossChanged(value,direction)
	if(not WindowName)then return end
	Vectors.SetAnchorValue(WindowName,AnchorIndex,direction,value)
	Settings.UpdateFromSource()
end


function Settings.ScaleClicked(step,direction)
	if(not WindowName)then return end
	Settings.DisableShowMinScale()
	Vectors.TickValue(WindowName,"scale",step)
	Settings.UpdateFromSource()
	Settings.PopulateScale()
end

function Settings.ScaleChanged(value,direction)
	if(not (WindowName and WindowData))then return end
	Settings.DisableShowMinScale()
	Vectors.SetValue(WindowName,"scale",value)
	local populate=WindowData.scale==nil
	Settings.UpdateFromSource()
	if(populate)then Settings.PopulateScale() end
end


function Settings.MinScaleClicked(step,direction)
	if(not (WindowName and WindowData))then return end
	Vectors.TickValue(WindowName,"minscale",step)
	if(originalscale)then Vectors.SetValue(WindowName,"scale",WindowData.minscale/InterfaceCore.GetScale()) end
	Settings.UpdateFromSource()
	Settings.PopulateMinScale()
end

function Settings.MinScaleChanged(value,direction)
	if(not (WindowName and WindowData))then return end
	Vectors.SetValue(WindowName,"minscale",value)
	if(originalscale)then Vectors.SetValue(WindowName,"scale",WindowData.minscale/InterfaceCore.GetScale()) end
	Settings.UpdateFromSource()
end

local LastMouseOverWindow
local LastUpdateTime=0
local FoundWindows
function Settings.OnUpdateInteractiveSelection()
	local window=SystemData.MouseOverWindow.name
	if(LastMouseOverWindow==window)then return end
	if(window=="Root" and LastUpdateTime+1>=GetComputerTime())then return end
	if(string_sub(window,1,string_len("EA_Window_ContextMenu"))=="EA_Window_ContextMenu")then return end
	if(string_sub(window,1,string_len("Vectors_Settings"))=="Vectors_Settings")
	then
		EA_Window_ContextMenu.HideAll()
		LastMouseOverWindow=window
	else
		Settings.ShowSelectOption(window)
	end
end

function Settings.ShowSelectOption(window)
	FoundWindows={}
	local parent=window
	local windows=Vectors.GetWindows()
	while(parent and parent~="Root")
	do
		if(windows[parent]~=nil)
		then
			ti(FoundWindows,parent)
		end
		parent=WindowGetParent(parent)
	end

	if(FoundWindows[1])
	then
		EA_Window_ContextMenu.CreateContextMenu(window)
		for _,k in ipairs(FoundWindows)
		do
			EA_Window_ContextMenu.AddMenuItem(towstring(k),Settings.SelectActive,false,true)
		end
		local x,y=WindowGetOffsetFromParent("CursorWindow")
		local iscale=InterfaceCore.GetScale()
		local xres_4,yres_4=SystemData.screenResolution.x/4,SystemData.screenResolution.y/4
		local RPfirst=(y*iscale)>(yres_4*3) and "bottom" or "top"
		local RPsecond=(x*iscale)>(xres_4*3) and "right" or "left"
		EA_Window_ContextMenu.Finalize(nil,{["RelativeTo"]="Root",["Point"]="topleft",["RelativePoint"]=RPfirst..RPsecond,["XOffset"]=x,["YOffset"]=y})
		LastUpdateTime=GetComputerTime()
	else
		EA_Window_ContextMenu.HideAll()
	end
	LastMouseOverWindow=window
end

function Settings.SelectActive()
	working=true
	local window=FoundWindows[WindowGetId(SystemData.ActiveWindow.name)]
	for i,k in ipairs(WindowIndex)
	do
		if(window==k)
		then
			ComboBoxSetSelectedMenuItem(SettingsWindow.."WindowComboBox",i)
			Settings.WindowChanged(i)
			break
		end
	end
	working=false
end


local ImportWindow="Vectors_Import"
local ImportProfileIndex,ImportRatioIndex
local ImportProfile,ImportRatio
function Settings.OpenImport()
	if(not DoesWindowExist(ImportWindow))
	then
		CreateWindow(ImportWindow,false)
	end
	WindowSetHandleInput("Vectors_Settings",false)
	Fader.FadeTo("Vectors_Settings",0.7)
	Fader.FadeTo(ImportWindow,1)

	LabelSetText(ImportWindow.."_Text",L"Overwrite your current Dataset with the following one.")
	local list=		{
						["_ImportProfiles"]		= L"Profiles",
						["_ImportRatios"]		= L"Ratios"
					}
	for i,k in pairs(list)
	do
		LabelSetText(ImportWindow..i.."Text",k)
	end
		list=		{
						["_CancelImport"]	= L"Cancel",
						["_Import"]			= L"Import"
					}
	for i,k in pairs(list)
	do
		ButtonSetText(ImportWindow..i,k)
	end

	local box=ImportWindow.."_ImportProfilesComboBox"
	ComboBoxClearMenuItems(box)
	ImportProfileIndex={}
	for i,k in pairs(Vectors.GetProfiles())
	do
		ComboBoxAddMenuItem(box,towstring(k))
		ti(ImportProfileIndex,k)
	end
	ComboBoxClearMenuItems(ImportWindow.."_ImportRatiosComboBox")
	ImportProfile=nil
	ImportRatio=nil
end

function Settings.CancelImport()
	WindowSetHandleInput("Vectors_Settings",true)
	Fader.FadeTo("Vectors_Settings",1)
	Fader.FadeTo(ImportWindow,0)
	ImportProfileIndex=nil
end

function Settings.Import()
	if(not(ImportProfile and ImportRatio))then return end
	Vectors.MakeCopyFrom(ImportProfile,ImportRatio)
	Settings.PopulateProfiles()
	Settings.CancelImport()
end

function Settings.ImportProfilesChanged(idx)
	ImportProfile=ImportProfileIndex[idx]
	local box=ImportWindow.."_ImportRatiosComboBox"
	ComboBoxClearMenuItems(box)
	ImportRatioIndex={}
	for i,k in pairs(Vectors.GetRatios())
	do
		ComboBoxAddMenuItem(box,(RATIOS[i] or wstring.format(L"%.2f",i)))
		ti(ImportRatioIndex,i)
	end
	ImportRatio=nil
end

function Settings.ImportRatiosChanged(idx)
	ImportRatio=ImportRatioIndex[idx]
end