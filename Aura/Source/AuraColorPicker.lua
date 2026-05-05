AuraColorPicker = {}

AuraColorPicker.Window 			= "AuraColorPicker"
AuraColorPicker.RedSlider 		= AuraColorPicker.Window .. "Red" 
AuraColorPicker.BlueSlider 		= AuraColorPicker.Window .. "Blue"
AuraColorPicker.GreenSlider 	= AuraColorPicker.Window .. "Green"
AuraColorPicker.AlphaSlider 	= AuraColorPicker.Window .. "Alpha"

function AuraColorPicker.OnLoad()

	WindowSetShowing( AuraColorPicker.Window, false )
	
	-- Set the label text
	LabelSetText( AuraColorPicker.Window .. "RedLabel", L"Red:" )
	LabelSetText( AuraColorPicker.Window .. "GreenLabel", L"Green:" )
	LabelSetText( AuraColorPicker.Window .. "BlueLabel", L"Blue:" )
	LabelSetText( AuraColorPicker.Window .. "AlphaLabel", L"Alpha:" )
end

function AuraColorPicker.OnHidden()
	WindowSetShowing( AuraColorPicker.Window, false )
end

function AuraColorPicker.OnSlide( pos )
	local r,b,g,a = 0
	
	-- Get the color settings
	r = SliderBarGetCurrentPosition( AuraColorPicker.RedSlider )
	g = SliderBarGetCurrentPosition( AuraColorPicker.GreenSlider )
	b = SliderBarGetCurrentPosition( AuraColorPicker.BlueSlider )
	a = SliderBarGetCurrentPosition( AuraColorPicker.AlphaSlider )
	
	r = AuraHelpers.round( r * 255, 0 )
	g = AuraHelpers.round( g * 255, 0 )
	b = AuraHelpers.round( b * 255, 0 )
	
	a = AuraHelpers.round( a, 2 )

	AuraConfig.HandleAuraColorPickerChange( r,g,b,a )	
end

function AuraColorPicker.SetColor( r, g, b, a)
	-- We are receiving ints for our colors, so convert them to 0.0 to 1.0 scale
	r = AuraHelpers.round( r / 255, 3 )
	g = AuraHelpers.round( g / 255, 3 )
	b = AuraHelpers.round( b / 255, 3 )
	a = AuraHelpers.round( a, 2 )
		
	SliderBarSetCurrentPosition( AuraColorPicker.RedSlider, r )
	SliderBarSetCurrentPosition( AuraColorPicker.GreenSlider, g )
	SliderBarSetCurrentPosition( AuraColorPicker.BlueSlider, b )
	SliderBarSetCurrentPosition( AuraColorPicker.AlphaSlider, a )
end

