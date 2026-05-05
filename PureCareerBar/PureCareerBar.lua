if not PureCareerBar then PureCareerBar = {} end

-- for compatiblity reasons
if not PurePlayer_Careerbar then PurePlayer_Careerbar = {} end

local firstLoad	= true

PureCareerBar.DefaultSettings 	=
{
	profile = {
		["enabled"]		= false,
		["color1"]		= {0, 100, 224},
		["color2"]		= {238, 116, 116},
		["color3"]		= {238, 12, 12},
	}
}

local db

if( PureTemplates ~= nil ) then
	PureTemplates.RegisterTemplate( PureTemplates.Types.PLAYER, "PurePlayer_Careerbar_Default", PurePlayerUnitFrame_CareerBar, L"PureCareerBar - Default" ) 
	PureTemplates.RegisterTemplate( PureTemplates.Types.PLAYER, "PurePlayer_Careerbar_Free", PurePlayerUnitFrame_CareerBar, L"PureCareerBar - Free" )
end

function PureCareerBar.GetDB()
	return db
end

function PureCareerBar.OnInitialize()

    --Init profile
    PureCareerBar.OnProfileChanged("OnInitialize")

    -- Set our db key
    db = Pure.GetDB().profile.templates.PureCareerBar    

	RegisterEventHandler( SystemData.Events.RELOAD_INTERFACE, "PureCareerBar.OnLoad" )
	RegisterEventHandler( SystemData.Events.LOADING_END, "PureCareerBar.OnLoad" )
end

function PureCareerBar.OnLoad()
	if( firstLoad ) then
		
		-- Register callbacks so we can initialize our settings if need be
		Pure.GetDB().RegisterCallback( PureCareerBar, "OnProfileChanged", PureCareerBar.OnProfileChanged )
		Pure.GetDB().RegisterCallback( PureCareerBar, "OnProfileCopied", PureCareerBar.OnProfileChanged )
		Pure.GetDB().RegisterCallback( PureCareerBar, "OnProfileReset", PureCareerBar.OnProfileChanged )
    
		firstLoad = false
	end
end

function PureCareerBar.OnProfileChanged( eventName )
	-- If our template table is nil, initialize it
	if( Pure.GetDB().profile.templates.PureCareerBar == nil ) then
		Pure.GetDB().profile.templates.PureCareerBar = DataUtils.CopyTable( PureCareerBar.DefaultSettings.profile )
	end
	
	-- Set our db key
	db = Pure.GetDB().profile.templates.PureCareerBar
end

function PureCareerBar.Get( key )
	if( db[key] == nil ) then
		d( "PureCareerBar.Get called with key that is nil:" .. tostring( key ) )
	end
	
	return db[key]
end

function PureCareerBar.Set( key, value )
	if( db[key] == nil ) then
		d( "PureCareerBar.Set called with key that is nil:" .. tostring( key ) )
	end

	db[key] = value
end

