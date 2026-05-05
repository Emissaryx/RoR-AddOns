if not WarBoard_TogglerEnemy then WarBoard_TogglerEnemy = {} end
local WarBoard_TogglerEnemy = WarBoard_TogglerEnemy
local modName = "WarBoard_TogglerEnemy"
local modLabel = "Enemy"

function WarBoard_TogglerEnemy.Initialize()
	if LibWBToggler.CreateToggler(modName, modLabel, "EnemyIcon_red", 0, 0) then
		WindowSetDimensions(modName, 110, 30)
		WindowSetDimensions(modName.."Label", 78, 30)
		LibWBToggler.RegisterEvent(modName, "OnLButtonUp", "WarBoard_TogglerEnemy.Intercom")
		LibWBToggler.RegisterEvent(modName, "OnRButtonUp", "WarBoard_TogglerEnemy.Configuration")
		LibWBToggler.RegisterEvent(modName, "OnMouseOver", "WarBoard_TogglerEnemy.ShowStatus")
		WarBoard_TogglerEnemy.enemyiconhook()
		
	end
end

function WarBoard_TogglerEnemy.Intercom()
	Enemy.TriggerEvent ("IconLButtonUp")
end

function WarBoard_TogglerEnemy.Configuration()
	EA_Window_ContextMenu.CreateContextMenu ("EnemyIcon")
	
	local data = {}
	Enemy.TriggerEvent ("IconCreateContextMenu", data)
	
	table.insert (data, {text = L"", callback = nil})
	table.insert (data, {text = L"Configuration", callback = Enemy.UI_ConfigDialog_Open})
	
	for _, d in pairs (data)
	do
		if (d.text == L"")
		then
			EA_Window_ContextMenu.AddMenuDivider ()
		else
			EA_Window_ContextMenu.AddMenuItem (d.text, d.callback, false, true)
		end
	end
	
	EA_Window_ContextMenu.Finalize ()
end

function WarBoard_TogglerEnemy.ShowStatus()
	LibWBToggler.DefaultTooltip(modName, modLabel)
end

function WarBoard_TogglerEnemy.enemyiconhook()
    local oldEnemyUI_Icon_Switch = Enemy.UI_Icon_Switch
    Enemy.UI_Icon_Switch =
        function(on,...)
            oldEnemyUI_Icon_Switch(on,...)
			DynamicImageSetTextureDimensions("WarBoard_TogglerEnemyIcon", 48, 48)
            if (on) then
                DynamicImageSetTexture ("WarBoard_TogglerEnemyIcon", "enemy_icon_active" , 0, 0)
            else
                DynamicImageSetTexture ("WarBoard_TogglerEnemyIcon", "enemy_icon_inactive", 0, 0)
            end
        end
end